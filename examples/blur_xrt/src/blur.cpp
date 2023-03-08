#include"blur.h"
// #ifdef CPU_VERSION
#include <unistd.h>
#include <pthread.h>
// #endif

#include "gaussian_filter_10_10.h"


extern "C" {

  void checkpoint() {}
  
  /*#FUNCTION_DEF#*/
  /* FUNC blur : ARGS newImage{}[10786293], image{}[10890000] */
  void blur(double* newImage, double* image, double* ckpt_mem){
    int d,i,j,h,w, ind;
    double l_sum0 = 0, l_sum1 = 0, l_sum2 = 0;
    int ckpt_id;
    
    // ckpt_mem[COMPLETED] = 0;

		printf("d=%d\n",d);
    ckpt_id = ckpt_mem[CKPT_ID]; 
    printf(">> blur: run from process PID = %d (ckpt id %d) %p\n>> ", getpid(), ckpt_id, ckpt_mem);

    for (d=0 ; d<NB_PASSES ; d++){
			printf("%d ", d);
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
			checkpoint();
      for(ind=0; ind<HEIGHT*WIDTH*3; ind++){
				image[ind] = newImage[ind];
      }
			checkpoint();
    }
  }

  /*#FUNCTION_DEF#*/
	/* FUNC workload : ARGS newImage{}[10786293], image{}[10890000] */
	int workload(double* newImage, double* image, double* ckpt_mem, int initial){
		printf("> workload%d: Starting workload\n", initial);

		blur(newImage, image, ckpt_mem);
		ckpt_mem[COMPLETED] = (initial==1)?0:1;

    printf("> workload%d: isComplete=%f\n", initial, ckpt_mem[COMPLETED]);
    return (int) ckpt_mem[COMPLETED];
	}
}

