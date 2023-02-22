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

// float mem_ckpt[CKPT_SIZE];
float* sh_mem_ckpt;
volatile float completed = 0;

float* result = NULL;
float* final_result = NULL;

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
  printf("Restore ID = %f\n", sh_mem_ckpt[CKPT_ID]);
  timespec timer3 = tic();
  blur(image, old_image, sh_mem_ckpt);
  toc(&timer3, "Final computation CPU");
}

void watchdog(float* old_image, float* new_image)
{
  static int previous_heartbeat = 0;
  while(keep_watchdog){

    // side-load ckpt data to test restore-only operation; check against final_result.txt
    // sh_mem_ckpt = new float[25]{8,1,1,0,0,0,0,11,12,13,14,15,16,17,18,19,20,21,22,4,3,4,3,99,0};

    // if((mem_ckpt[0] == previous_heartbeat) && (!running_cpu_kernel) && (previous_heartbeat>0)){
    if((sh_mem_ckpt[0] == previous_heartbeat) && (!running_cpu_kernel) && (previous_heartbeat>0)){
      printf("$     ## Re-run workload\n");
      // kernel ckpt has not been updated in time => recovery process
      running_cpu_kernel = true;
      backup_thread(old_image, new_image);
      printf("$     ## completed=%f\n", completed);
      break;
    }
    // previous_heartbeat = mem_ckpt[0];
    previous_heartbeat = sh_mem_ckpt[0];
    usleep(20000);
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
  int failure_delay_ms = 2000;
  std::cout << "argc = " << argc << std::endl;

  for(int i=2; i < argc; i++){
    if(strcmp("--failure", argv[i]) == 0){
      if((i+1)>argc)
	printf("Invalid time failure\n");
      else
	failure_delay_ms = atoi(argv[i+1]);
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

  sh_mem_ckpt = (float *) create_shared_memory(CKPT_SIZE*sizeof(float));

  //reset mem_ckpt
  memset(sh_mem_ckpt, 0, CKPT_SIZE*sizeof(float));
  

  pid_t pid;
  //create a child process
  //thus making 2 processes run at the same time
  //Store the Process ID in 'pid'
  pid = fork();
  if(pid==0){
    std::cout<<"Output from the child process."<< std::endl;
    std::cout << "Pid : " << getpid() << std::endl;

    printf("CKPT_SIZE=%d\n", CKPT_SIZE);

    // printf("mem_ckpt[0]=%f, mem_ckpt[1]=%f\n", mem_ckpt[0], mem_ckpt[1]);
    printf("mem_ckpt[0]=%f, mem_ckpt[1]=%f\n", sh_mem_ckpt[0], sh_mem_ckpt[1]);

    killer_tid = std::thread(killer_thread, failure_delay_ms);
    blur(new_image, old_image, sh_mem_ckpt);

    // check sh_mem_ckpt content against result.txt for save-only operation
    std::cout<<"print sh_mem_ckpt:"<<std::endl;
    for(int i=0; i<10; i++){
      printf("  end(%d) sh_mem_ckpt[%d]=%f\n", pid, i, sh_mem_ckpt[i]);
    }

    /*
    for (int p=0; p<size*size; p++)
    {
      printf("child: result[%d]=%f\n", p, result[p]);
    }
    */

    pid = getpid();

    if(completed == 0)
      printf("Process %d: Uncompleted process\n", pid);

    // std::cout<<"print sh_mem_ckpt:"<<std::endl;
    // for(int i=0; i<CKPT_SIZE; i++){
    //   printf("  end(%d) sh_mem_ckpt[%d]=%f\n", pid, i, sh_mem_ckpt[i]);
    // }

    printf("Child process finished, isCompleted=%f\n",completed);
    
  }else{
    std::cout <<"Output from the parent process."<< std::endl;
    std::cout << "Pid : " << getpid() << std::endl;
    pid = getpid();
    
    std::thread thread_obj(watchdog, old_image, new_image);
    while(completed != 1) usleep(20000);

    /*
    for (int p=0; p<size*size; p++)
    {
      printf("parent: final_result[%d]=%f\n", p, final_result[p]);
    }
    */

    keep_watchdog = false;
    thread_obj.join();
    printf("Joined\n");

  }
  
  if(sh_mem_ckpt[COMPLETED] == 1){
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
