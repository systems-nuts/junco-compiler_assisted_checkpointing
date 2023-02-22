#ifndef HEARTBEATS_H
#define HEARTBEATS_H

extern "C"{
  void heartbeat(unsigned int ticks_failure, unsigned int* output);
};

#endif
