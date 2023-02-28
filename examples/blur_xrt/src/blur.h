#ifndef BLUR_H
#define BLUR_H

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// #define COMPLETED 0
// #define HEARTBEAT 1
// #define CKPT_ID   2
// #define VAR1      3
// #define VAR2      4
// #define OUTPUTS   5
#define HEARTBEAT     0
#define CKPT_ID       1
#define COMPLETED     2
#define VAR1      3
#define RESULT    4

// Image size
#define HEIGHT 1650
#define WIDTH 2200

// Blur filter parameters
#define FILTER_WIDTH 10
#define FILTER_HEIGHT 10
#define NB_PASSES 3

#define newImageHeight (HEIGHT-FILTER_HEIGHT+1) // 1650-10+1=1641
#define newImageWidth (WIDTH-FILTER_WIDTH+1)    // 2200-10+1=2191

// #define CKPT_SIZE = 28763484  // taken from ckpt_sizes_bytes.json

typedef unsigned char uchar;

extern pthread_mutex_t lock;

extern "C"{
  void blur(float* newImage, float* image, float* ckpt_mem);
  int workload(float* newImage, float* image, float* ckpt_mem, int initial);
};

#endif
