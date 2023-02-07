#ifndef LOCAL_SUPPORT_H
#define LOCAL_SUPPORT_H

#include "my_timer.h"
#include"lud.h"

#define DEBUG_PRINT

#define TCP_IP_CHUNK_SIZE 1024
#define BACKUP_PERIOD_US 10000 //10ms
#define PORT_NUM 5001
#define SERVER_IP_ADDR "127.0.0.1"

extern volatile bool end_heartbeats;

int kernel_launcher(int initial_run, int fpga_target, const char * input_file, float * ckpt_mem = NULL, int failure_delay_ms=-1);
void* input_bench_to_data(const char* data_file_name);
  
void heatbeat_thread(const char* dest_ip, float* ckpt_mem, int size);
void backup_app(float * ckpt_mem, const char * input_file);

#endif
