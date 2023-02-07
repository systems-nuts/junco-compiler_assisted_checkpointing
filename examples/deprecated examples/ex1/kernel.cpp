#include <iostream>

extern "C"{

  int workload(int* ckpt_mem)
  {
    int l_id = 0;

    printf("Start of function: workload\n");
    
    //checkpoint / restore here
    //l_id = ckpt_mem[0];
    //ckpt_mem[0] = 1;
    
    if(l_id != 0){
      printf("The task has been restored! l_id = %d\n", l_id);
      return 1;
    }else{
      printf("The task has NOT been restored! l_id = %d\n", l_id);
      return 0;
    }
    return -1;
  }

}
