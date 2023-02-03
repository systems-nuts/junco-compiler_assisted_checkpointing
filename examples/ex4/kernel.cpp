#include <iostream>

// chpt mem def
#define HEARTBEAT 0
#define CKPT_ID 1
// #define VAR 2
#define IS_COMPLETE 2
#define VAR 3

extern "C"{

  void checkpoint(){}
  
  int workload(int ckpt_mem[6], int initial)
  {
    int l_id = 0;

    printf("Start of function: workload\n");

    if(initial==1){
      l_id = 1;
    }
    
    //checkpoint / restore here
    checkpoint();

    printf("initial=%d\n", initial);

    if(initial==1){
      printf("Initial ");
    }
    printf("process l_id = %d, ckpt_mem ptr %p, heartbeat %d, CKPT_ID %d, VAR_0 %d, VAR_1 %d, VAR_2 %d\n", 
                    l_id, ckpt_mem, ckpt_mem[HEARTBEAT], ckpt_mem[CKPT_ID], ckpt_mem[VAR], ckpt_mem[VAR+1], ckpt_mem[VAR+2]);
    
    return ((initial==1)?0:1);
  }

}
