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
  
  /*#FUNCTION_DEF#*/
  float workload(float ckpt_mem[8], float initial, float arr[2])
  {
    float l_id = 0;

    // memcpy(&ckpt_mem[3], arr, 2*sizeof(int));
    // memcpy(arr, &ckpt_mem[3], 2*sizeof(int));

    printf("Start of function: workload. l_id=%f\n", l_id);
    std::cout<<"ckpt_mem="<<ckpt_mem<<", arr="<<arr<<std::endl;
    // end of entry.upper

    if(initial == (float) 1){
      // start of if.then
      std::cout<<">> initial == 1:"<<std::endl;
      l_id = 7;
      std::cout<<">> l_id = 7"<<std::endl;
      arr[0] = 19;
      std::cout<<">> arr[0] = 19"<<std::endl;
      arr[1] = 96;
      std::cout<<">> arr[1] = 96"<<std::endl;
    }

    printf("initial=%f, arr[0]=%f, arr[1]=%f\n", initial, arr[0], arr[1]);
    std::cout<<"BEFORE CKPT"<<std::endl;
    
    //checkpoint / restore here
    checkpoint();

    std::cout<<"AFTER CKPT"<<std::endl;

    if(initial==1){
      printf("Initial ");
    }
    printf("arr[0] = %f, arr[1] = %f\n", arr[0], arr[1]);
    printf("process l_id = %f, ckpt_mem ptr %p, heartbeat %f, CKPT_ID %f, VAR_0 %f, VAR_1 %f, VAR_2 %f, VAR_3 %f, VAR_4 %f\n", 
                    l_id, ckpt_mem, ckpt_mem[HEARTBEAT], ckpt_mem[CKPT_ID], ckpt_mem[VAR], ckpt_mem[VAR+1], ckpt_mem[VAR+2], ckpt_mem[VAR+3], ckpt_mem[VAR+4]);
    
    return ((initial == (float) 1) ? (float)0 : (float)1);
  }

}
