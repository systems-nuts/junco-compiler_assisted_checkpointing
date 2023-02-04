#include <iostream>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <thread>
#include <sys/mman.h>

#define CKPT_SIZE 8

extern "C" int workload(int* ckpt_mem, int initial, int *arr);

volatile bool keep_watchdog = true;

int mem_ckpt[CKPT_SIZE];

int* sh_mem_ckpt;
volatile int completed = 0;

void watchdog(void)
{
  static int previous_heartbeat = 0;
  static bool running_cpu_kernel = false;
  while(keep_watchdog){
    // Get last checkpoint
    memcpy(mem_ckpt, sh_mem_ckpt, CKPT_SIZE*sizeof(int));
    // is it alive (heartbeat check)
    printf("$  In watchdog; mem_ckpt[0]=%d, running_cpu_kernel=%d, previous_heartbeat=%d\n", mem_ckpt[0], running_cpu_kernel, previous_heartbeat);
    if((mem_ckpt[0] == previous_heartbeat) && (!running_cpu_kernel) && (previous_heartbeat>0)){
      printf("$     ## Re-run workload\n");
      // kernel ckpt has not been updated in time => recovery process
      running_cpu_kernel = true;
      int arr[2] = {33,33};
      completed = workload(mem_ckpt, 0, arr);
      printf("$     ## completed=%d\n", completed);
    }
    previous_heartbeat = mem_ckpt[0];
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
  

int main(int argc, char** argv) {

  std::cout << "argc = " << argc << std::endl;
  for(int i=0; i < argc; i++){
    std::cout << "argv[" << i << "] = " << argv[i] << std::endl;
  }

  sh_mem_ckpt = (int *) create_shared_memory(CKPT_SIZE*sizeof(int));
    
  pid_t pid;
  //create a child process
  //thus making 2 processes run at the same time
  //Store the Process ID in 'pid'
  pid = fork();
  if(pid==0){
    std::cout<<"Output from the child process."<< std::endl;
    std::cout << "Pid : " << getpid() << std::endl;
    int arr[2] = {44,44};
    completed = workload(sh_mem_ckpt, 1, arr);
    pid = getpid();

    if(completed == 0)
      printf("Process %d: Uncompleted process\n", pid);
    
    for(int i=0; i<CKPT_SIZE; i++){
      printf("end(%d) ckpt_mem[%d]=%d\n", pid, i, mem_ckpt[i]);
    }
    
  }else{
    std::cout <<"Output from the parent process."<< std::endl;
    std::cout << "Pid : " << getpid() << std::endl;
    pid = getpid();
    
    std::thread thread_obj(watchdog);
    while(completed != 1){usleep(20000);}

    keep_watchdog = false;
    thread_obj.join();
    
    for(int i=0; i<CKPT_SIZE; i++){
      printf("end(%d) ckpt_mem[%d]=%d\n", pid, i, mem_ckpt[i]);
    }
    
    printf("\n free memory\n");
    munmap(sh_mem_ckpt, CKPT_SIZE*sizeof(int));
  }
}
