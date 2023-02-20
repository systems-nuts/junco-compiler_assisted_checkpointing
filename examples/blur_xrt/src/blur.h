#ifndef BLUR_H
#define BLUR_H

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define COMPLETED 0
#define HEARTBEAT 1
#define CKPT_ID   2
#define VAR1      3
#define VAR2      4
#define OUTPUTS   5

// Image size
#define HEIGHT 1650
#define WIDTH 2200

// Blur filter parameters
#define FILTER_WIDTH 10
#define FILTER_HEIGHT 10
#define NB_PASSES 3

#define newImageHeight (HEIGHT-FILTER_HEIGHT+1)
#define newImageWidth (WIDTH-FILTER_WIDTH+1)

typedef unsigned char uchar;

extern pthread_mutex_t lock;

extern "C"{
  void blur(float* newImage, float* image, float* mem_ckpt);
};

#endif
