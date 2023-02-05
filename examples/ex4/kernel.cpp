#include <iostream>
#include <string.h>

// chpt mem def
#define HEARTBEAT 0
#define CKPT_ID 1
// #define VAR 2
#define IS_COMPLETE 2
#define VAR 3

extern "C"{

  void checkpoint(){}
  
  int workload(int ckpt_mem[8], int initial, int arr[2])
  {
    int l_id = 0;

    // memcpy(&ckpt_mem[3], arr, 2*sizeof(int));
    // memcpy(arr, &ckpt_mem[3], 2*sizeof(int));

    printf("Start of function: workload. l_id=%d\n", l_id);
    std::cout<<"ckpt_mem="<<ckpt_mem<<", arr="<<arr<<std::endl;
    // end of entry.upper

    if(initial==1){
      // start of if.then
      std::cout<<">> initial == 1:"<<std::endl;
      l_id = 7;
      std::cout<<">> l_id = 7"<<std::endl;
      arr[0] = 19;
      std::cout<<">> arr[0] = 19"<<std::endl;
      arr[1] = 96;
      std::cout<<">> arr[1] = 96"<<std::endl;
    }

    printf("initial=%d, arr[0]=%d, arr[1]=%d\n", initial, arr[0], arr[1]);
    std::cout<<"BEFORE CKPT"<<std::endl;
    
    //checkpoint / restore here
    checkpoint();

    std::cout<<"AFTER CKPT"<<std::endl;

    if(initial==1){
      printf("Initial ");
    }
    printf("arr[0] = %d, arr[1] = %d\n", arr[0], arr[1]);
    printf("process l_id = %d, ckpt_mem ptr %p, heartbeat %d, CKPT_ID %d, VAR_0 %d, VAR_1 %d, VAR_2 %d, VAR_3 %d, VAR_4 %d\n", 
                    l_id, ckpt_mem, ckpt_mem[HEARTBEAT], ckpt_mem[CKPT_ID], ckpt_mem[VAR], ckpt_mem[VAR+1], ckpt_mem[VAR+2], ckpt_mem[VAR+3], ckpt_mem[VAR+4]);
    
    return ((initial==1)?0:1);
  }

}
