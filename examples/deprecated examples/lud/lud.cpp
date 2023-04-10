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
  void lud(float result[1048576], int size, float ckpt_mem[1048584], int ckpt_id)
  {
    int i, j, k; 
    float sum;
    int init_i = 0;
    
    ckpt_mem[COMPLETED] = 0;
    
    printf("lud run from process PID = %d (ckpt id %d) %p\n", getpid(), ckpt_id, ckpt_mem);

    for (i=init_i; i<size; i++){
      for (j=i; j<size; j++){
        sum=result[i*size+j];
        for (k=0; k<i; k++) sum -= result[i*size+k]*result[k*size+j];
        result[i*size+j]=sum;
      }
      
      for (j=i+1;j<size; j++){
        sum=result[j*size+i];
        for (k=0; k<i; k++) sum -= result[j*size+k]*result[k*size+i];
        result[j*size+i]=sum/result[i*size+i];
      }
      checkpoint();
      
    }

    ckpt_mem[COMPLETED] = 1;
    return;
  }
  
  /*#FUNCTION_DEF#*/
  void workload(float result[1048576], int size, float ckpt_mem[1048584])
  {

    #pragma HLS INTERFACE m_axi port=result offset=slave bundle=gmem
    #pragma HLS INTERFACE m_axi port=ckpt_mem offset=slave bundle=gmem
    #pragma HLS INTERFACE s_axilite port=result bundle=control
    #pragma HLS INTERFACE s_axilite port=size bundle=control
    #pragma HLS INTERFACE s_axilite port=ckpt_mem bundle=control
    #pragma HLS INTERFACE s_axilite port=return bundle=control
    
    int ckpt_id = ckpt_mem[CKPT_ID];
    lud(result, size, ckpt_mem, ckpt_id);
        
    return;
    
  }
}
