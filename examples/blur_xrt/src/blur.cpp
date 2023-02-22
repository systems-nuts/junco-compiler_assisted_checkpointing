#include"blur.h"
#ifdef CPU_VERSION
#include <unistd.h>
#include <pthread.h>
#endif

#include "gaussian_filter_10_10.h"


extern "C" {

  void checkpoint() {}
  
  void blur(float* newImage, float* image, float* mem_ckpt){

#pragma HLS INTERFACE m_axi port=newImage offset=slave bundle=gmem
#pragma HLS INTERFACE m_axi port=image offset=slave bundle=gmem
#pragma HLS INTERFACE m_axi port=mem_ckpt offset=slave bundle=gmem1
#pragma HLS INTERFACE s_axilite port=newImage bundle=control
#pragma HLS INTERFACE s_axilite port=image bundle=control
#pragma HLS INTERFACE s_axilite port=mem_ckpt bundle=control
#pragma HLS INTERFACE s_axilite port=return bundle=control

    int d,i,j,h,w, ind;
    float l_sum0 = 0, l_sum1 = 0, l_sum2 = 0;
    int checkpoint_id;
    
    mem_ckpt[COMPLETED] = 0;

    checkpoint_id = mem_ckpt[CKPT_ID]; 
    
    for (d=0 ; d<NB_PASSES ; d++){
      for (i=0 ; i<newImageHeight ; i++) {
	for (j=0 ; j<newImageWidth ; j++) {
	  for (h=0 ; h<FILTER_HEIGHT ; h++) {
	    for (w=0 ; w<FILTER_WIDTH ; w++) {
	      l_sum0 += filter[(h*FILTER_WIDTH)+(w)]*image[(0*HEIGHT*WIDTH)+((h+i)*WIDTH)+(w+j)];
	      l_sum1 += filter[(h*FILTER_WIDTH)+(w)]*image[(1*HEIGHT*WIDTH)+((h+i)*WIDTH)+(w+j)];
	      l_sum2 += filter[(h*FILTER_WIDTH)+(w)]*image[(2*HEIGHT*WIDTH)+((h+i)*WIDTH)+(w+j)];
	    }
	  }
	  newImage[(0*HEIGHT*WIDTH)+(i*WIDTH)+j] = l_sum0;
	  newImage[(1*HEIGHT*WIDTH)+(i*WIDTH)+j] = l_sum1;
	  newImage[(2*HEIGHT*WIDTH)+(i*WIDTH)+j] = l_sum2;
	  l_sum0 = 0;
	  l_sum1 = 0;
	  l_sum2 = 0;
	}
	checkpoint();
      }
      for(ind=0; ind<HEIGHT*WIDTH*3; ind++){
	image[ind] = newImage[ind];
      }
    }
  }
}

