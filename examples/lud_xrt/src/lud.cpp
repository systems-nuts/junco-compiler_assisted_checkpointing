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
  /* FUNC lud : ARGS result{}[1048576], size{const} */
  void lud(double* result, int size, double* ckpt_mem, int ckpt_id)
  {
    int i, j, k; 
    double sum;
    int init_i = 0;
    // double localArray[3][3]; // testing:
    
    printf(">> lud: run from process PID = %d (ckpt id %d) %p\n>> ", getpid(), ckpt_id, ckpt_mem);

    for (i=init_i; i<size; i++){
      // printf(">> lud: assign local array\n");
      // localArray[1][1] = 1234567; // testing
      // localArray[0][2] = 54321; // testing

      for (j=i; j<size; j++){
        sum=result[i*size+j];
        for (k=0; k<i; k++) sum -= result[i*size+k]*result[k*size+j];
        result[i*size+j]=sum;
        // checkpoint(); // lvl 2 ckpt
      }
      checkpoint(); // lvl 1 ckpt

      for (j=i+1;j<size; j++){
        sum=result[j*size+i];
        for (k=0; k<i; k++) sum -= result[j*size+k]*result[k*size+i];
        result[j*size+i]=sum/result[i*size+i];
        // printf(".");
        // checkpoint(); // lvl 2 ckpt
      }

      // for (int p=0; p<size*size; p++)
      // {
      //   printf(">> lud: i=%d, result[%d]=%f\n", i, p, result[p]);
      // }

      checkpoint(); // lvl 1 ckpt
      // printf("%d ", i);
    }
    // printf("\n>> lud: local_array[1][1] aft restore = %f\n", localArray[1][1]); // testing
    // printf(">> lud: local_array[0][2] aft restore = %f\n", localArray[0][2]); // testing
    printf(">> lud: after checkpoint\n");
    // printf(">> lud: localArray[10] = %f\n", localArray[10]);

    return;
  }
  
  /*#FUNCTION_DEF#*/
  /* FUNC workload : ARGS result{}[1048576], size{} */
  int workload(double* result, int size, double* ckpt_mem, int initial)
  {
    printf("> workload: Starting workload\n");
    
    int ckpt_id = ckpt_mem[CKPT_ID];
    lud(result, size, ckpt_mem, ckpt_id);
    ckpt_mem[COMPLETED] = ((initial==1)?0:1);

    // for (int p=0; p<size*size; p++)
    // {
    //   printf("> workoad: result[%d]=%f\n", p, result[p]);
    // }
        
    //return;
    printf("> workload: isComplete=%f\n", ckpt_mem[COMPLETED]);
    return (int) ckpt_mem[COMPLETED];
  }
}
