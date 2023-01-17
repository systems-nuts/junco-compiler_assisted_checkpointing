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

#define CKPT_SIZE 5

typedef unsigned char uchar;

extern pthread_mutex_t lock;

extern "C"{
  void blur(float* newImage, float* image, float* mem_ckpt);
};

#endif
