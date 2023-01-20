#include <iostream>

extern "C"{

  void checkpoint(){}
  
  int workload(int* ckpt_mem)
  {
    int l_id = 0;

    printf("Start of function: workload\n");
    
    //checkpoint / restore here
    checkpoint();
    
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
