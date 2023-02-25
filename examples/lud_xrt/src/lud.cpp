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

  void checkpoint(){}
  
  /*#FUNCTION_DEF#*/
  /* FUNC lud : ARGS result[256], ckpt_mem[281] */
  void lud(float* result, int size, float* ckpt_mem, int ckpt_id)
  {
    int i, j, k; 
    float sum;
    int init_i = 0;
    // testing:
    float localArray[16];
    localArray[10] = 1234567;
    
    // ckpt_mem[COMPLETED] = 0;
    
    printf(">> lud: run from process PID = %d (ckpt id %d) %p\n>> ", getpid(), ckpt_id, ckpt_mem);

    for (i=init_i; i<size; i++){
      // printf("<");
      for (j=i; j<size; j++){
        sum=result[i*size+j];
        for (k=0; k<i; k++) sum -= result[i*size+k]*result[k*size+j];
        result[i*size+j]=sum;
      }
      // printf("~");
      
      for (j=i+1;j<size; j++){
        sum=result[j*size+i];
        for (k=0; k<i; k++) sum -= result[j*size+k]*result[k*size+i];
        result[j*size+i]=sum/result[i*size+i];
      }

      // for (int p=0; p<size*size; p++)
      // {
      //   printf(">> lud: i=%d, result[%d]=%f\n", i, p, result[p]);
      // }

      // testing:
      // printf(">> slide-load arr elem\n");
      ckpt_mem[10] = localArray[10];
      printf("ckpt_mem[10] = %f\n", ckpt_mem[10]);
      // ckpt_mem[10] = tmp;
      checkpoint();
      printf("%d ", i);
      // printf(">>\n");
    }
    printf("\n>> lud: after checkpoint\n");
    printf(">> lud: localArray[10] = %d\n", localArray[10]);

    // ckpt_mem[COMPLETED] = 1;
    return;
    // return ((initial==1)?0:1);
    // return result;
  }
  
  /*#FUNCTION_DEF#*/
  /* FUNC workload : ARGS result[256], ckpt_mem[281] */
  int workload(float* result, int size, float* ckpt_mem, int initial)
  {
    printf("> workload: Starting workload\n");
    
    int ckpt_id = ckpt_mem[CKPT_ID];
    lud(result, size, ckpt_mem, ckpt_id);
    ckpt_mem[COMPLETED] = ((initial==1)?0:1);

    for (int p=0; p<size*size; p++)
    {
      printf("> workoad: result[%d]=%f\n", p, result[p]);
    }
        
    //return;
    printf("> workload: isComplete=%f\n", ckpt_mem[COMPLETED]);
    return (int) ckpt_mem[COMPLETED];
  }
}
