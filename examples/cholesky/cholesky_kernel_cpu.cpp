/*
 * Copyright 2020 Xilinx, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#include "cholesky_kernel.hpp"
#include <stdio.h>


extern "C" {

  void checkpoint(){};

  /*#FUNCTION_DEF#*/
  /* FUNC cholesky_kernel : ARGS diagSize{}[], matrixA{}[42250] */
  void cholesky_kernel(int diagSize, dataType* matrixA, dataType* ckpt_mem) {
    
    printf(">> cholesky_kernel\n");
    printf(">> ckpt_mem[3] = %f\n", ckpt_mem[3]);
      
    dataType dataA[MAXN_K][MAXN_K];
    
    for(int i = 0; i < diagSize; i++){
      for (int j = 0; j < diagSize; j++) {
	      dataA[i][j] = matrixA[i*diagSize + j];
      }
    }
    checkpoint();
    
    dataType tmp1=sqrt(dataA[0][0]);
    
    dataA[0][0] = tmp1;
    Loop_first_col:
    for (int i = 1; i < diagSize; i++){
      dataA[i][0] = dataA[i][0]/tmp1;
    }
    checkpoint();
    
    Loop_col:
    for (int j = 1; j < diagSize; ++j){
      dataType tmp = 0;
      
      Loop_diag:
      for(int k = 0; k < j; k++){
	      tmp += dataA[j][k]*dataA[j][k];
      }
      checkpoint();
      dataA[j][j] = sqrt(dataA[j][j] - tmp);
      
      if (j < diagSize - 1){
        Loop_row:
        for(int i = j+1; i < diagSize; ++i){
          dataType tmp2=0;
          Loop_vec_mul:
          for(int k = 0; k < j; k++){
                  tmp2 += dataA[i][k]*dataA[j][k];
          }
          dataA[i][j] = (dataA[i][j] - tmp2)/dataA[j][j];
        }
      }
      checkpoint();
      printf("%d ", j);
    }
    
    for (int i = 0; i < diagSize; i++) {
      for (int j = 0; j < diagSize; j++) {
	      matrixA[i * diagSize + j] = dataA[i][j];
      }
    }
    printf("\n>> end kernel\n");
    printf(">> ckpt_mem[3] = %f\n", ckpt_mem[3]);
  }

  /*#FUNCTION_DEF#*/
  /* FUNC workload : ARGS diagSize{}[], matrixA{}[42250] */
  int workload(int diagSize, dataType* matrixA, dataType* ckpt_mem, int initial)
  {
    printf("> workload: Starting workload\n");
    
    int ckpt_id = ckpt_mem[CKPT_ID];
    cholesky_kernel(diagSize, matrixA, ckpt_mem);
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
