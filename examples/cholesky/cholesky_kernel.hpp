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


// #include "ap_fixed.h"
#include <stdint.h>
// #include "hls_math.h"
#include <math.h>

#define HEARTBEAT     0
#define CKPT_ID       1
#define COMPLETED     2

#define dataType double
#define MAXN_K 512  /** TODO: enter size here */
#define NCU 4

/** TODO: update size here */
// CKPT_SIZE = (num of discrete metadata) + (largest val from ckpt_sizes_bytes_json) / 4
#define CKPT_SIZE (3 + 2097184/8) // must have brackets around arithmetic!

extern "C" {
  void cholesky_kernel(int diagSize, dataType* matrixA, dataType* ckpt_mem);
  void checkpoint();
} 

