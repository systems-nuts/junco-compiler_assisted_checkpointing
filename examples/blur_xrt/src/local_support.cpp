#include "local_support.h"
#include "blur.h"
#include "heartbeat.h"
#include "ckpt_mem_def.h"
#include <string.h>
#include <fstream>
#include <iostream>
#include <unistd.h>    /* standard unix functions, like alarm()          */
#include <signal.h>
#include <thread>
#include <stdexcept>
#include <sys/types.h>
#include <vector>
#include <functional>

#include <sys/mman.h>
#include <stdlib.h>

#define _POSIX_SOURCE
#include <sys/wait.h>

#ifdef FPGA_TARGET
// XRT includes
#include "xrt/xrt_bo.h"
#include <experimental/xrt_xclbin.h>
#include "xrt/xrt_device.h"
#include "xrt/xrt_kernel.h"
#endif

#define USE_FLOAT

#define METADATA_NUM 3
#define CKPT_SIZE (int(CKPT_MEM_SIZE/sizeof(float))+METADATA_NUM)

typedef void (*fp)();

#define GET_RAND_FP ( (float)rand() /   \
                     ((float)(RAND_MAX)+(float)(1)) )

#define MIN(i,j) ((i)<(j) ? (i) : (j))

// #define BACKUP_PERIOD_US 100000 //100ms
#define HEARTBEAT_PERIOD_US 100000 //100ms


#define DEBUG_PRINT

extern "C" void blur(float* newImage, float* image, float* mem_ckpt);

volatile bool keep_watchdog = true;
static bool running_cpu_kernel = false;
volatile bool is_child_complete = false;

volatile bool backup_thread_running = false;

float mem_ckpt[CKPT_SIZE];
float mem_ckpt_ref[CKPT_SIZE];
volatile float completed = 0;

float* result = NULL;
float* final_result = NULL;

#ifdef FPGA_TARGET
xrt::bo ckpt_buffer;
xrt::bo heartbeat_buffer;
#endif

unsigned int g_heartbeat[2] = {5, 5};

void axis_move_2_to_0(uchar* dest, uchar* source, int height, int width, int channels){
  int i,j,d;
  for(i=0;i<height;i++){
    for(j=0;j<width;j++){
        for(d=0;d<channels;d++){
	  dest[(d*height*width)+(i*width)+j]=source[(i*width*channels)+(j*channels)+d];
	}
    }
  }
}

void axis_move_0_to_2(uchar* dest, uchar* source, int height, int width, int channels){
  int i,j,d;
  for(d=0;d<channels;d++){
    for(i=0;i<height;i++){
      for(j=0;j<width;j++){
	dest[(i*width*channels)+(j*channels)+d]=source[(d*height*width)+(i*width)+j];
      }
    }
  }
}


/** Thread simulating the application crash */
void killer_thread(int delay_ms){
  usleep(delay_ms*1000);
  printf("Early stop\n");
  kill(getpid(), 9);
}

void backup_thread(float* old_image, float* image){
  // printf("Restore ID = %f\n", mem_ckpt[CKPT_ID]);
  printf("Restore ID = %f \n", mem_ckpt[CKPT_ID]);
  timespec timer3 = tic();
  blur(image, old_image, mem_ckpt);
  toc(&timer3, "Final computation CPU");
}

void watchdog(float* old_image, float* new_image)
{
  static int previous_heartbeat = 0;

  for(int i=0; i<10; i++){
      printf("watch mem_ckpt[%d] = %f\n", i, mem_ckpt[i]);
  }
  
  while(keep_watchdog){
    // Get last checkpoint
#ifdef FPGA_TARGET
    printf("Ckpt backup\n");
    ckpt_buffer.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
    ckpt_buffer.read(mem_ckpt);
    heartbeat_buffer.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
    heartbeat_buffer.read(g_heartbeat);
    printf("Data transfered\n");
    for(int i=0; i<3; i++){
      printf("mem_ckpt[%d] = %f\n", i, mem_ckpt[i]);
    }
    printf("\n");
#endif
#ifdef DEBUG_PRINT
    printf("watchdog => prev HB %d new HB %d\n", previous_heartbeat, g_heartbeat[0]);
#endif
    // is it alive (heartbeat check)
    if((g_heartbeat[0] == previous_heartbeat) && (!backup_thread_running) && (previous_heartbeat>0)){
#ifdef DEBUG_PRINT
    printf("FAILURE DETECTED. RUN BACKUP\n");
#endif
      // kernel ckpt has not been updated in time => recovery process
      backup_thread_running = true;
      backup_thread(old_image, new_image);
      break;
    }
    previous_heartbeat = g_heartbeat[0];
    usleep(HEARTBEAT_PERIOD_US);
  }
}

void* create_shared_memory(size_t size) {
  // Our memory buffer will be readable and writable:
  int protection = PROT_READ | PROT_WRITE;

  // The buffer will be shared (meaning other processes can access it), but
  // anonymous (meaning third-party processes cannot obtain an address for it),
  // so only this process and its children will be able to use it:
  int visibility = MAP_SHARED | MAP_ANONYMOUS;

  // The remaining parameters to `mmap()` are not important for this use case,
  // but the manpage for `mmap` explains their purpose.
  return mmap(NULL, size, protection, visibility, -1, 0);
}

int arrToFile(float* arr, int arrSize, std::string filename) {
  std::ofstream myfile (filename);
  if (myfile.is_open()) {
    for(int i=0; i < arrSize; i ++) {
      myfile << arr[i] << "\n";
    }
    myfile.close();
    return 1;
  }
  else std::cout << "Unable to open file";
  return 0;
}


int main(int argc, char** argv) {

  std::thread killer_tid;
  int failure_delay_ticks = 1000;
  std::cout << "argc = " << argc << std::endl;

  for(int i=2; i < argc; i++){
    if(strcmp("--failure", argv[i]) == 0){
      if((i+1)>argc)
	printf("Invalid time failure\n");
      else
	failure_delay_ticks = atoi(argv[i+1]);
    }
  }

  char * in_file = argv[1];
  
  int width, height, channels;
  uchar * image_data = stbi_load(in_file, &width, &height, &channels, 0);
  std::size_t size = width * height * channels;
  printf("Source image: %s %dx%d (%d)\n", in_file, width, height, channels);

  // temporary data
  uchar * imageD = new uchar[size];
#ifdef USE_FLOAT
  float * new_image = new float[size];
  float * old_image = new float[size];
#else
  uchar * new_image = new uchar[size];
  uchar * old_image = new uchar[size];
#endif

  //printf("height %d, width %d, channels %d\n", height, width, channels);
  
  axis_move_2_to_0(imageD, image_data, height, width, channels);

  // channels copy r,g,b
  for(std::size_t i = 0; i < size; ++i)
    {
#ifdef USE_FLOAT
      old_image[i] = (float)imageD[i]/1.0;// / 255.f;
#else
      old_image[i] = imageD[i];
#endif
    }

  // Read settings
  std::string binaryFile = "./xclbin/blur.hw.xilinx_u50_gen3x16_xdma_201920_3.xclbin"; //argv[2];
  int device_index = 0;

  std::cout << "Open the device" << device_index << std::endl;
  auto device = xrt::device(device_index);
  std::cout << "Load the xclbin " << binaryFile << std::endl;
  auto uuid = device.load_xclbin(binaryFile);

  auto krnl = xrt::kernel(device, uuid, "blur", xrt::kernel::cu_access_mode::exclusive);
  auto krnl2 = xrt::kernel(device, uuid, "heartbeat", xrt::kernel::cu_access_mode::exclusive);

  printf("size %d\n", size);

  std::cout << "Allocate Buffer in Global Memory, checkpoint mem size " << CKPT_SIZE << "(" << CKPT_SIZE*sizeof(float) << ")" << std::endl;

  auto old_image_buffer = xrt::bo(device, size*sizeof(float), krnl.group_id(0));
  auto new_image_buffer = xrt::bo(device, size*sizeof(float), krnl.group_id(1));

  ckpt_buffer = xrt::bo(device, CKPT_SIZE*sizeof(float), krnl.group_id(2));
  
  heartbeat_buffer = xrt::bo(device, 2*sizeof(unsigned int), krnl2.group_id(1)); //Match kernel arguments to RTL kernel
  
  std::cout << "XRT Buffer ok\n";

  //reset mem_ckpt
  memset(mem_ckpt, 0, CKPT_SIZE*sizeof(float));

  printf("Start Kernel computation\n");

  mem_ckpt[COMPLETED] = 0;

  // 0th: initialize the timer at the beginning of the program
  timespec timer = tic();
  
  // Write our data set into device buffers
  old_image_buffer.write(old_image);
  old_image_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE);

  ckpt_buffer.write(mem_ckpt);
  ckpt_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE);
  
  // Execute the kernel over the entire range of our 1d input data set
  // using the maximum number of work group items for this device
  //
  
  //ualarm(BACKUP_PERIOD_US, 0);
  std::thread thread_obj(watchdog, old_image, new_image);

  //std::thread killer_tid = std::thread(killer_thread, failure_delay_ms);
  
  std::cout << "Execution of the kernel\n";
  auto run2 = krnl2(failure_delay_ticks, heartbeat_buffer);
  auto run = krnl(new_image_buffer, old_image_buffer, ckpt_buffer);
  printf("wait\n");
  //run.wait();
  //run2.wait();

  while(mem_ckpt[COMPLETED] != 1){usleep(20);}
  
  
  // 4th: time of kernel execution
  toc(&timer, "kernel execution");

  //heartbeat_buffer.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
  //heartbeat_buffer.read(g_heartbeat);
  //printf("=> g_heartbeat[0] = %d\n", g_heartbeat[0]);
  //printf("=> g_heartbeat[1] = %d\n", g_heartbeat[1]);
  
  // Read back the results from the device to verify the output
  if(!backup_thread_running){
    new_image_buffer.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
    new_image_buffer.read(new_image);
    ckpt_buffer.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
    ckpt_buffer.read(mem_ckpt);
    
    // 5th: time of data retrieving (PCIe + memcpy)
    toc(&timer, "data retrieving");

    for(int i=0; i<10; i++){
      printf("result[%d] = %f\n", i, result[i]);
    }
    
    final_result = result;
  }
  // Register restore functions

  //run2.wait();
  //heartbeat_buffer.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
  //heartbeat_buffer.read(g_heartbeat);  
  //printf("heartbeat %d\n", g_heartbeat[0]);  

  for(int i=0; i<11; i++){
    printf("end mem_ckpt[%d] = %f\n", i, mem_ckpt[i]);
  }
    
  keep_watchdog = false;
  thread_obj.join();

  if(mem_ckpt[COMPLETED] == 1){
    printf("Application completed");
    // convert result
    for(std::size_t i = 0; i < size; ++i)
      {
#ifdef USE_FLOAT
	imageD[i] = (uchar)std::round(new_image[i]);// * 255.f);
#else
	imageD[i] = (uchar)(new_image[i]);
#endif
      }
    
    axis_move_0_to_2(image_data, imageD, height, width, channels);
    
    // save image
    stbi_write_jpg("out.jpg", width, height, channels, image_data, 90);
  }
    
  printf("\n free memory\n");
  delete[] new_image;
  delete[] old_image;
}
