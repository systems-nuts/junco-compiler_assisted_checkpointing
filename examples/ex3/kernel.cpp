#include <iostream>

// chpt mem def
#define HEARTBEAT 0
#define CKPT_ID 1
// #define VAR 2
#define IS_COMPLETE 2
#define VAR 3

extern "C"{

  void checkpoint(){}
  
  int workload(int ckpt_mem[1024])
  {
    int l_id = 0;

    printf("Start of function: workload\n");

    if(ckpt_mem[CKPT_ID] == 0){
      l_id = 1;
    }
    
    //checkpoint / restore here
    checkpoint();
    
    if(l_id == 1){
      printf("The task has been restored! l_id = %d\n", l_id);
      return 1;
    }else{
      printf("The task has NOT been restored! l_id = %d\n", l_id);
      return 0;
    }
    return -1;
  }

}
