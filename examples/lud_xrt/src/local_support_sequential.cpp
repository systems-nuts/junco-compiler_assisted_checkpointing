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

typedef void (*fp)();

#define GET_RAND_FP ( (double)rand() /   \
                     ((double)(RAND_MAX)+(double)(1)) )

#define MIN(i,j) ((i)<(j) ? (i) : (j))

// #define BACKUP_PERIOD_US 100000 //100ms
#define HEARTBEAT_PERIOD_US 100000 //100ms


#define DEBUG_PRINT

extern "C" int workload(double *result, int size, double *ckpt_mem, int initial);
extern "C" int workload_restore(double *result, int size, double *ckpt_mem, int initial);

volatile bool keep_watchdog = true;
static bool running_cpu_kernel = false;
volatile bool is_child_complete = false;

double* sh_mem_ckpt;
volatile double completed = 0;

int size = 512;  /** TODO: maybe don't hard-code?*/
// int size = 1024;
// int size = 3072;

double* result = NULL;
double* final_result = NULL;

void backup_thread(int size){
  printf("Restore ID = %f\n", sh_mem_ckpt[CKPT_ID]);
  final_result = (double*) malloc(size*size*sizeof(double));
  timespec timer2 = tic();
  completed = workload_restore(final_result, size, sh_mem_ckpt, 0);
  toc(&timer2, "==Computation Restored from CKPT");
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

int create_matrix_from_random(double *mp, int size){
  double *l, *u, *m;
  int i,j,k;

  srand(time(NULL));

  m = mp;

  l = (double*)malloc(size*size*sizeof(double));
  if ( l == NULL)
    return -1;

  u = (double*)malloc(size*size*sizeof(double));
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

int arrToFile(double* arr, int arrSize, std::string filename) {
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

  std::cout << "argc = " << argc << std::endl;
  for(int i=0; i < argc; i++){
    std::cout << "argv[" << i << "] = " << argv[i] << std::endl;
  }

  // Read settings
  std::string binaryFile = argv[2];
  int device_index = 0;

  printf("size %d\n", size);

  sh_mem_ckpt = (double *) create_shared_memory(CKPT_SIZE*sizeof(double));

  result = (double *) create_shared_memory(size*size*sizeof(double));

  create_matrix_from_random(result, size);


  std::cout<<"Output from the child process."<< std::endl;
  std::cout << "Pid : " << getpid() << std::endl;

  printf("CKPT_SIZE=%d\n", CKPT_SIZE);

  // printf("mem_ckpt[0]=%f, mem_ckpt[1]=%f\n", sh_mem_ckpt[0], sh_mem_ckpt[1]);

  timespec timer = tic();
  completed = workload(result, size, sh_mem_ckpt, 1);
  toc(&timer, "==Initial computation CPU");

  // for (int p=0; p<size*size; p++)
  // {
  //   printf("child: result[%d]=%f\n", p, result[p]);
  // }

  // std::cout<<"print sh_mem_ckpt:"<<std::endl;
  // for(int i=0; i<CKPT_SIZE; i++){
  //   printf("  end(%d) sh_mem_ckpt[%d]=%f\n", pid, i, sh_mem_ckpt[i]);
  // }

  printf("First process finished, isCompleted=%f\n",completed);

  printf("$     ## Re-run workload\n");
  // kernel ckpt has not been updated in time => recovery process
  running_cpu_kernel = true;
  backup_thread(size);
  printf("$     ## completed=%f\n", completed);

  // for (int p=0; p<size*size; p++)
  // {
  //   printf("parent: final_result[%d]=%f\n", p, final_result[p]);
  // }

  arrToFile(sh_mem_ckpt, CKPT_SIZE, "sh_mem_ckpt.txt");
  arrToFile(result, size*size, "result.txt");
  arrToFile(final_result, size*size, "final_result.txt");

  // check result
  bool is_match = true;
  for (int i=0; i<size*size; i++){
    if(result[i] != final_result[i]){
      printf("Error: Results diff result[%d]=%f != final_result[%d]=%f\n", i, result[i], i, final_result[i]);
      is_match = false;
      break;
    }
  }
  if (is_match) printf("Results match!\n");

  printf("\n free memory\n");
  munmap(sh_mem_ckpt, CKPT_SIZE*sizeof(double));
  if(running_cpu_kernel)
    free(final_result);
  
}