#include "local_support.h"
#include "lud.h"
#include "heartbeat.h"
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

typedef void (*fp)();

#define GET_RAND_FP ( (float)rand() /   \
                     ((float)(RAND_MAX)+(float)(1)) )

#define MIN(i,j) ((i)<(j) ? (i) : (j))

#define BACKUP_PERIOD_US 100000 //100ms
#define HEARTBEAT_PERIOD_US 100000 //100ms


#define DEBUG_PRINT

volatile bool keep_watchdog = true;
volatile bool backup_thread_running = false;

#ifdef FPGA_TARGET
  xrt::bo ckpt_buffer;
  xrt::bo heartbeat_buffer;
#endif

struct bench_args_dyn_t *args;
float* mem_ckpt;

float* final_result = NULL;


unsigned int g_heartbeat[2] = {5, 5};

void killer_thread(unsigned int delay_ms){
  printf("killer_thread is running");
  usleep(delay_ms*1000);
  int status = system("xbutil reset --device 0000:01:00 --force");
}

void backup_thread(int size){
  printf("Restore ID = %f\n", mem_ckpt[CKPT_ID]);
  final_result = (float*) malloc(size*size*sizeof(float));
  lud(final_result, size, mem_ckpt, mem_ckpt[CKPT_ID]);
}

void watchdog(int size)
{
  static int previous_heartbeat = 0;

  for(int i=0; i<CKPT_SIZE; i++){
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
      for(int i=0; i<CKPT_SIZE; i++){
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
      backup_thread(size);
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
  
int INPUT_SIZE = sizeof(struct bench_args_t);

int create_matrix_from_random(float *mp, int size){
  float *l, *u, *m;
  int i,j,k;

  srand(time(NULL));

  m = mp;

  l = (float*)malloc(size*size*sizeof(float));
  if ( l == NULL)
    return -1;

  u = (float*)malloc(size*size*sizeof(float));
  if ( u == NULL) {
    free(l);
    return -1;
  }

  for (i = 0; i < size; i++) {
    for (j=0; j < size; j++) {
      if (i>j) {
        l[i*size+j] = GET_RAND_FP;
      } else if (i == j) {
        l[i*size+j] = 1;
      } else {
        l[i*size+j] = 0;
      }
    }
  }

  for (j=0; j < size; j++) {
    for (i=0; i < size; i++) {
      if (i>j) {
          u[j*size+i] = 0;
      }else {
          u[j*size+i] = GET_RAND_FP; 
      }
    }
  }

  for (i=0; i < size; i++) {
    for (j=0; j < size; j++) {
      for (k=0; k <= MIN(i,j); k++)
        m[i*size+j] = l[i*size+k] * u[j*size+k];
    }
  }

  free(l);
  free(u);

  //*mp = m;

  return 1;
}

void* input_bench_to_data(const char* data_file_name)
{
  struct bench_args_dyn_t *data = (struct bench_args_dyn_t *) malloc(sizeof(struct bench_args_dyn_t));

  {
    std::ifstream file(data_file_name);
    if(!file.is_open()){
      throw(std::string("can not find/open file!"));
    }
    file >> data->size;
  }
  return (void*) data;
}


int main(int argc, char** argv) {

  int failure_delay_ticks = 1000;
  std::cout << "argc = " << argc << std::endl;
  for(int i=0; i < argc; i++){
    std::cout << "argv[" << i << "] = " << argv[i] << std::endl;
    if(strcmp("--failure", argv[i]) == 0){
      if((i+1)>argc)
	printf("Invalid time failure\n");
      else
	failure_delay_ticks = atoi(argv[i+1]);
    }

  }
  // Read settings
  std::string binaryFile = argv[2];
  //std::string binaryFile = "./vadd.xclbin";
  //int device_index = (int)argv[2];
  int device_index = 0;
  
  std::cout << "Open the device" << device_index << std::endl;
  auto device = xrt::device(device_index);
  std::cout << "Load the xclbin " << binaryFile << std::endl;
  auto uuid = device.load_xclbin(binaryFile);
  
  args = (struct bench_args_dyn_t *) input_bench_to_data(argv[1]);
  
  printf("size %d\n", args->size);

  auto krnl = xrt::kernel(device, uuid, "workload", xrt::kernel::cu_access_mode::exclusive);
  auto krnl2 = xrt::kernel(device, uuid, "heartbeat", xrt::kernel::cu_access_mode::exclusive);
  
  std::cout << "Allocate Buffer in Global Memory\n";
  auto result_buffer = xrt::bo(device, args->size*args->size*sizeof(float), krnl.group_id(0)); //Match kernel arguments to RTL kernel
  ckpt_buffer = xrt::bo(device, CKPT_SIZE*sizeof(float)+args->size*args->size*sizeof(float), krnl.group_id(2));
  
  heartbeat_buffer = xrt::bo(device, 2*sizeof(unsigned int), krnl2.group_id(1)); //Match kernel arguments to RTL kernel
  
  std::cout << "XRT Buffer ok\n";
  
  // Map the contents of the buffer object into host memory
  args->result = result_buffer.map<float*>();
  mem_ckpt = (float*) malloc(CKPT_SIZE*sizeof(float)+args->size*args->size*sizeof(float));
  for(int ind=0; ind<CKPT_SIZE; ind++){
    mem_ckpt[ind] = 0;
  }
  //mem_ckpt = ckpt_buffer.map<float*>();
    
  create_matrix_from_random(args->result, args->size);


  // Validation computation
  float * resultConfirm = (float *) malloc(args->size*args->size*sizeof(float));
  memcpy(resultConfirm, args->result, args->size*args->size*sizeof(float));
  // Confirmation Result computation
  timespec timerCPU = tic();
  lud(resultConfirm, args->size, mem_ckpt, 3);
  mem_ckpt[COMPLETED] = 0;
  toc(&timerCPU, "Validation kernel execution");

  for(int ind=0; ind<CKPT_SIZE; ind++){
    mem_ckpt[ind] = 0;
  }

  // 0th: initialize the timer at the beginning of the program
  timespec timer = tic();
  
  // Write our data set into device buffers
  result_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE);
  ckpt_buffer.write(mem_ckpt);
  ckpt_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE);
  
  // Execute the kernel over the entire range of our 1d input data set
  // using the maximum number of work group items for this device
  //
  
  //ualarm(BACKUP_PERIOD_US, 0);
  std::thread thread_obj(watchdog, args->size);

  //std::thread killer_tid = std::thread(killer_thread, failure_delay_ms);
  
  std::cout << "Execution of the kernel\n";
  auto run2 = krnl2(failure_delay_ticks, heartbeat_buffer);
  auto run = krnl(result_buffer, args->size, ckpt_buffer);
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
    result_buffer.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
    ckpt_buffer.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
    ckpt_buffer.read(mem_ckpt);
    // 5th: time of data retrieving (PCIe + memcpy)
    toc(&timer, "data retrieving");
    final_result = args->result;
  }
  // Register restore functions

  //run2.wait();
  //heartbeat_buffer.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
  //heartbeat_buffer.read(g_heartbeat);  
  //printf("heartbeat %d\n", g_heartbeat[0]);  

  for(int i=0; i<CKPT_SIZE; i++){
    printf("end mem_ckpt[%d] = %f\n", i, mem_ckpt[i]);
  }

  //CHECK RESULT
  for (int i=0; i<args->size*args->size; i++){
    if(resultConfirm[i] != final_result[i]){
      printf("Error: Results diff resultConfirm[%d]=%f != result[%d]=%f\n", i, resultConfirm[i], i, final_result[i]);
      break;
    }
  }
    
  keep_watchdog = false;
  thread_obj.join();
    
  printf("\n free memory\n");
  if(backup_thread_running)
    free(final_result);
  //free(args->result);
  free(args);
}
