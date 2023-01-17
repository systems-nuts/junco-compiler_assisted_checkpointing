#include"blur.h"
#ifdef CPU_VERSION
#include <unistd.h>
#include <pthread.h>
#endif

#include "gaussian_filter_10_10.h"

#define filterHeight 10
#define filterWidth 10
#define height 1650
#define width 2200
#define nb_passes 10

#define newImageHeight height-filterHeight+1
#define newImageWidth width-filterWidth+1

extern "C" {

  static unsigned int heartbeat = 0;

  void checkpoint(float* ckpt_mem, int d, int i, float* ouputs, int size, int id, char inst) {
    #pragma HLS INLINE OFF
    #pragma HLS FUNCTION_INSTANTIATE variable=inst

    #ifdef CPU_VERSION
      pthread_mutex_lock(&lock);
    #endif
    
    ckpt_mem[HEARTBEAT] = heartbeat++;
    ckpt_mem[CKPT_ID] = id;
    ckpt_mem[VAR1] = d;
    ckpt_mem[VAR2] = i;
    memcpy(&ckpt_mem[OUTPUTS], ouputs, size*sizeof(float));

    #ifdef CPU_VERSION
      pthread_mutex_unlock(&lock);
    #endif
  }
  
  void blur(float* newImage, float* image, float* mem_ckpt){

    #pragma HLS INTERFACE m_axi port=newImage offset=slave bundle=gmem
    #pragma HLS INTERFACE m_axi port=image offset=slave bundle=gmem
    #pragma HLS INTERFACE m_axi port=mem_ckpt offset=slave bundle=gmem1
    #pragma HLS INTERFACE s_axilite port=newImage bundle=control
    #pragma HLS INTERFACE s_axilite port=image bundle=control
    #pragma HLS INTERFACE s_axilite port=mem_ckpt bundle=control
    #pragma HLS INTERFACE s_axilite port=return bundle=control

    int d,i,j,h,w, ind;
    int init_i = 0;
    int init_d = 0;
    float l_sum0 = 0, l_sum1 = 0, l_sum2 = 0;
    
    mem_ckpt[COMPLETED] = 0;

    if(mem_ckpt[CKPT_ID] == 1){
      init_d = (int) mem_ckpt[VAR1];
      init_i = (int) mem_ckpt[VAR2]+1;
      for (int ind=0; ind<height*width*3; ind++){
	      newImage[ind] = mem_ckpt[OUTPUTS+ind]; 
      }
    }

    for (d=init_d ; d<nb_passes ; d++){
      for (i=init_i ; i<newImageHeight ; i++) {
        for (j=0 ; j<newImageWidth ; j++) {
          for (h=0 ; h<filterHeight ; h++) {
            for (w=0 ; w<filterWidth ; w++) {
              l_sum0 += filter[(h*filterWidth)+(w)]*image[(0*height*width)+((h+i)*width)+(w+j)];
              l_sum1 += filter[(h*filterWidth)+(w)]*image[(1*height*width)+((h+i)*width)+(w+j)];
              l_sum2 += filter[(h*filterWidth)+(w)]*image[(2*height*width)+((h+i)*width)+(w+j)];
            }
          }
          newImage[(0*height*width)+(i*width)+j] = l_sum0;
          newImage[(1*height*width)+(i*width)+j] = l_sum1;
          newImage[(2*height*width)+(i*width)+j] = l_sum2;
          l_sum0 = 0;
          l_sum1 = 0;
          l_sum2 = 0;
        }
        #ifdef CPU_VERSION
        if(mem_ckpt[CKPT_ID] != 1){
          checkpoint(mem_ckpt, d, i, newImage, height*width*3, 1, 1);
        }
        #endif
      }
      for(ind=0; ind<height*width*3; ind++){
	    image[ind] = newImage[ind];
      }
    }
    mem_ckpt[COMPLETED] = 1;
    mem_ckpt[VAR1] = d;
    mem_ckpt[VAR2] = i;
  }
}

