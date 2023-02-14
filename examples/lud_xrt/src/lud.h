#ifndef LUD_H
#define LUD_H

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// #define COMPLETED 0
// #define HEARTBEAT 1
// #define CKPT_ID   2
#define HEARTBEAT     0
#define CKPT_ID       1
#define COMPLETED     2
#define VAR1      3
#define RESULT    4

#define GRID_ROWS 256
#define GRID_COLS 256
#define SIZE GRID_ROWS
#define TILE_ROWS 4
#define PARA_FACTOR 8
#define TOP 0
#define BOTTOM (GRID_ROWS / TILE_ROWS - 1)

// #define CKPT_SIZE 4
// CKPT_SIZE = (num of discrete metadata) + (largest val from ckpt_sizes_bytes_json) / 4
#define CKPT_SIZE (1024*1024 + 6 + 3) // must have brackets around arithmetic!

#define TYPE float

struct bench_args_t {
    float result[GRID_ROWS * GRID_COLS];
};

struct bench_args_dyn_t {
  int size;
  float* result;
};

extern pthread_mutex_t lock;

extern "C"{
  void lud(float* result, int size, float* ckpt_mem, int ckpt_id = 0);
};

// void workload(float result[GRID_ROWS * GRID_COLS]);
#endif
