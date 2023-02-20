#ifndef MY_TIMER_H
#define MY_TIMER_H

typedef struct timespec timespec;

timespec tic( );
void toc( timespec* start_time, const char* prefix );
void timedPrint(const char* str);

#endif
