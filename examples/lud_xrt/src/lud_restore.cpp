#include"lud.h"
#include <pthread.h>
#ifndef FPGA_TARGET
#include <unistd.h>
#endif

#include <iostream>
#include <fstream>
#include <string.h>

extern "C"{

  static unsigned int heartbeat = 0;
  
  /*#FUNCTION_DEF#*/
  /* FUNC lud_restore : ARGS result{}[262144], size{}[] */
  void lud_restore(double* result, int size, double* ckpt_mem, int ckpt_id)
  {
    int i, j, k; 
    double sum;
    int init_i = 0;
    
    printf(">> lud: run from process PID = %d (ckpt id %d) %p\n>> ", getpid(), ckpt_id, ckpt_mem);

    for (i=init_i; i<size; i++){

      for (j=i; j<size; j++){
        sum=result[i*size+j];
        for (k=0; k<i; k++) sum -= result[i*size+k]*result[k*size+j];
        result[i*size+j]=sum;
        // checkpoint(); // lvl 2 ckpt
      }
      // checkpoint(); // lvl 1 ckpt

      for (j=i+1;j<size; j++){
        sum=result[j*size+i];
        for (k=0; k<i; k++) sum -= result[j*size+k]*result[k*size+i];
        result[j*size+i]=sum/result[i*size+i];
        // checkpoint(); // lvl 2 ckpt
      }

      if (i % 1 == 0) {
        checkpoint(); // lvl 1 ckpt
      } 
      // checkpoint(); // lvl 1 ckpt
      // printf("%d ", i);
    }
    printf(">> lud: after checkpoint");

    return;
  }
  
  /*#FUNCTION_DEF#*/
  /* FUNC workload_restore : ARGS result{}[262144], size{const}[] */
  int workload_restore(double* result, int size, double* ckpt_mem, int initial)
  {
    printf("> workload: Starting workload\n");
    
    int ckpt_id = ckpt_mem[CKPT_ID];
    lud_restore(result, size, ckpt_mem, ckpt_id);
    ckpt_mem[COMPLETED] = ((initial==1)?0:1);
        
    printf("> workload: isComplete=%f\n", ckpt_mem[COMPLETED]);
    return (int) ckpt_mem[COMPLETED];
  }
}