#include"heartbeat.h"
#include <pthread.h>
#ifndef FPGA_TARGET
#include <unistd.h>
#endif

extern "C"{
  
  void heartbeat(unsigned int ticks_failure, unsigned int output[2])
  {
#pragma HLS INTERFACE m_axi port=output offset=slave bundle=gmem
#pragma HLS INTERFACE s_axilite port=ticks_failure bundle=control
#pragma HLS INTERFACE s_axilite port=output bundle=control
#pragma HLS INTERFACE s_axilite port=return bundle=control
    
    unsigned int l_heartbeat = 0, i;
    //while(1){
    //  i++;
    for(i=0; l_heartbeat<1000000; i++) { 
#pragma HLS latency min=1000 max=1000
      if((i%1000000) == 0)
	output[0] = l_heartbeat++;
      if(l_heartbeat>ticks_failure)
	break;
    }
    /*
    for(l_heartbeat=0; l_heartbeat<100000; l_heartbeat++) { 
#pragma HLS latency min=100 max=100
      output[0] = l_heartbeat;
      output[1] = l_heartbeat*4;
    }
    */
  }
}
