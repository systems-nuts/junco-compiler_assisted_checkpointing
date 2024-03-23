#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

extern "C"
{

#define MM_SEED_SEG_SHIFT  48
#define MM_SEED_SEG_MASK   (0xffULL<<(MM_SEED_SEG_SHIFT))

#define TRIPCOUNT_PER_SUBPART 64
#define MAX_SUBPARTS 8

#define PREFETCH_BUFFER_SIZE 64

typedef double dataType;

char sync_bit = 0;
/** DALE: Below is the allocated array size for the index-tracking stack.
 * This value is defined already in SubroutineInjection.h compiler pass header file.
 * Make sure that the values are consistent! (Or shared)
 * This value is paired with a stackArraySizeMask var to avoid stack overflow. */ 
const int stackArraySize = 0x00010000;

void cpy_wrapper_f(dataType* dest, void* src, int size){
	memcpy(dest, src, size);
	sync_bit = 1;
}

void cpy_wrapper_i8(unsigned char* dest, unsigned char* src, int size){
	memcpy(dest, src, size);
	sync_bit = 1;
}

void __attribute__ ((noinline)) mem_cpy_index_f(dataType* dest, void* src, int* index_list, int* sp, int size){
    if(dest == NULL)
      return;

		if (*sp > stackArraySize)
		{
			// printf("  sp value exceed array size ==> copy whole array!\n");
			memcpy(dest, src, size);
			return;
		}

		/** TODO: implement element-wise type conversion here */
		char *src_t = (char*) src;
    while(*sp>0){
      (*sp)--;
      int index = index_list[*sp];
      dest[index] = src_t[index];
    }

    sync_bit = 1;
  }

void checkpoint(){mem_cpy_index_f(NULL, NULL, NULL, NULL, NULL);cpy_wrapper_f(NULL, NULL, 0);cpy_wrapper_i8(NULL, NULL, 0);}

char LogTable256[256] = {
#define LT(n) n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n
	-1, 0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3,
	LT(4), LT(5), LT(5), LT(6), LT(6), LT(6), LT(6),
	LT(7), LT(7), LT(7), LT(7), LT(7), LT(7), LT(7), LT(7)
};

inline int ilog2_32(unsigned int v)
{
	unsigned int t, tt;
	if ((tt = v>>16)) return (t = tt>>8) ? 24 + LogTable256[t] : 16 + LogTable256[tt];
	return (t = v>>8) ? 8 + LogTable256[t] : LogTable256[v];
}

/*#FUNCTION_DEF#*/
/* FUNC chain : ARGS a{}[132456], f{}[132456], p{}[132456] */
void chain(long total_subparts,
					int max_dist_x, int max_dist_y, int bw, int q_span, float avg_qspan_scaled, 
					const long * a,
					int * f, int * p,
					const unsigned char * num_subparts,
					dataType* ckpt_mem)
{
	unsigned long a_x_local[TRIPCOUNT_PER_SUBPART * MAX_SUBPARTS + 1] = {0};
	int a_y_local[TRIPCOUNT_PER_SUBPART * MAX_SUBPARTS + 1] = {0};
	int f_local[TRIPCOUNT_PER_SUBPART * MAX_SUBPARTS + 1] = {0};

    unsigned char subparts_processed = 0;
	unsigned char subparts_to_process = 0;

	long a_local_next[PREFETCH_BUFFER_SIZE * 2];
	unsigned char subparts_to_process_next[PREFETCH_BUFFER_SIZE];

	for (int j = 0; j < PREFETCH_BUFFER_SIZE; j++) {
		a_local_next[j*2] = a[j*2];
		a_local_next[j*2+1] = a[j*2+1];

		subparts_to_process_next[j] =  num_subparts[j];
	}

	int prefetch_ptr = PREFETCH_BUFFER_SIZE;

	// fill the score and backtrack arrays
    long i = 0;
	for (long g = 0; g < total_subparts; ++g) {
		if (subparts_processed == 0) {
			long a_local_x = a_local_next[0];
			long a_local_y = a_local_next[1];
			a_x_local[0] = a_local_x;
			a_y_local[0] = (int)a_local_y;
			subparts_to_process = subparts_to_process_next[0];

			for (int j = 0; j < PREFETCH_BUFFER_SIZE - 1; j++) {
				a_local_next[j*2] = a_local_next[j*2 + 2];
				a_local_next[j*2 + 1] = a_local_next[j*2 + 1 + 2];
				subparts_to_process_next[j] = subparts_to_process_next[j + 1];
			}

			a_local_next[PREFETCH_BUFFER_SIZE - 2] = a[prefetch_ptr];
			a_local_next[PREFETCH_BUFFER_SIZE - 2 + 1] = a[prefetch_ptr+1];
            subparts_to_process_next[PREFETCH_BUFFER_SIZE - 1] = num_subparts[prefetch_ptr];
			prefetch_ptr++;
      }
		
		unsigned long ri = a_x_local[0];
		int qi = a_y_local[0];
		
		unsigned long sc_a[TRIPCOUNT_PER_SUBPART] = {0};

		for (int j = TRIPCOUNT_PER_SUBPART; j > 0; j--) {
			unsigned long a_x_local_j, a_y_local_j;
			int f_local_j;

			if (subparts_processed == 0) {
				a_x_local_j = a_x_local[j];
				a_y_local_j = a_y_local[j];
				f_local_j = f_local[j];
			}
			if (subparts_processed == 1) {
                a_x_local_j = a_x_local[TRIPCOUNT_PER_SUBPART + j];
				a_y_local_j = a_y_local[TRIPCOUNT_PER_SUBPART + j];
				f_local_j = f_local[TRIPCOUNT_PER_SUBPART + j];
            } 
			if (subparts_processed == 2) {
                a_x_local_j = a_x_local[2 * TRIPCOUNT_PER_SUBPART + j];
				a_y_local_j = a_y_local[2 * TRIPCOUNT_PER_SUBPART + j];
				f_local_j = f_local[2 * TRIPCOUNT_PER_SUBPART + j];
            } 
			if (subparts_processed == 3) {
                a_x_local_j = a_x_local[3 * TRIPCOUNT_PER_SUBPART + j];
				a_y_local_j = a_y_local[3 * TRIPCOUNT_PER_SUBPART + j];
				f_local_j = f_local[3 * TRIPCOUNT_PER_SUBPART + j];
            } 
			if (subparts_processed == 4) {
                a_x_local_j = a_x_local[4 * TRIPCOUNT_PER_SUBPART + j];
				a_y_local_j = a_y_local[4 * TRIPCOUNT_PER_SUBPART + j];
				f_local_j = f_local[4 * TRIPCOUNT_PER_SUBPART + j];
            } 
			if (subparts_processed == 5) {
                a_x_local_j = a_x_local[5 * TRIPCOUNT_PER_SUBPART + j];
				a_y_local_j = a_y_local[5 * TRIPCOUNT_PER_SUBPART + j];
				f_local_j = f_local[5 * TRIPCOUNT_PER_SUBPART + j];
            } 
			if (subparts_processed == 6) {
                a_x_local_j = a_x_local[6 * TRIPCOUNT_PER_SUBPART + j];
				a_y_local_j = a_y_local[6 * TRIPCOUNT_PER_SUBPART + j];
				f_local_j = f_local[6 * TRIPCOUNT_PER_SUBPART + j];
            } 
			if (subparts_processed == 7) {
                a_x_local_j = a_x_local[7 * TRIPCOUNT_PER_SUBPART + j];
				a_y_local_j = a_y_local[7 * TRIPCOUNT_PER_SUBPART + j];
				f_local_j = f_local[7 * TRIPCOUNT_PER_SUBPART + j];
            }

			long dr = ri - a_x_local_j; 
			if (dr > max_dist_x || dr <= 0) continue; // to serve "st"'s purpose (kisaru) 
			int dq = qi - (int)a_y_local_j, dd, log_dd;
			if (dq <= 0) continue; // don't skip if an anchor is used by multiple segments; see below
			if (dq > max_dist_y || dq > max_dist_x) continue;
			dd = dr > dq? dr - dq : dq - dr;
			if (dd > bw) continue;
			int min_d = dq < dr? dq : dr;
			int sc = min_d > q_span? q_span : dq < dr? dq : dr;
			log_dd = dd? ilog2_32(dd) : 0;
			sc -= (int)(dd * avg_qspan_scaled) + (log_dd>>1);
			sc += f_local_j;

			sc_a[j - 1] = sc;
		}

		long max_j = -1;
		int max_f = q_span;

		for (int j = TRIPCOUNT_PER_SUBPART; j > 0; j--) {
			int sc = sc_a[j - 1];
			if (sc >= max_f && sc != q_span) {
				max_f = sc;
                if (subparts_processed == 0) max_j = i - j;
                if (subparts_processed == 1) max_j = i - j - TRIPCOUNT_PER_SUBPART;
                if (subparts_processed == 2) max_j = i - j - 2 * TRIPCOUNT_PER_SUBPART;
                if (subparts_processed == 3) max_j = i - j - 3 * TRIPCOUNT_PER_SUBPART;
                if (subparts_processed == 4) max_j = i - j - 4 * TRIPCOUNT_PER_SUBPART;
                if (subparts_processed == 5) max_j = i - j - 5 * TRIPCOUNT_PER_SUBPART;
                if (subparts_processed == 6) max_j = i - j - 6 * TRIPCOUNT_PER_SUBPART;
                if (subparts_processed == 7) max_j = i - j - 7 * TRIPCOUNT_PER_SUBPART;
			}
		}

        if (max_f > f_local[0]) {
            f[i] = max_f;
            p[i] = max_j;
            f_local[0] = max_f;
        }

        subparts_processed++;
        
        for (int reg = TRIPCOUNT_PER_SUBPART * MAX_SUBPARTS; reg > 0; reg--) {
            if (subparts_processed == subparts_to_process) {
                f_local[reg] = f_local[reg - 1];
                a_x_local[reg] = a_x_local[reg - 1];
                a_y_local[reg] = a_y_local[reg - 1];
            }
        }

        if (subparts_processed == subparts_to_process) {
            f_local[0] = 0;
			i++;
			subparts_processed = 0;
        }

		checkpoint();      
	}
}

}




// /*#FUNCTION_DEF#*/
// /* FUNC chain : ARGS a{}[132456], f{}[132456], p{}[132456]*/
// void chain0(long total_subparts,
//                          int max_dist_x, int max_dist_y, int bw, int q_span, float avg_qspan_scaled, 
// 						 const ulong2 * a,
//                          int * f, int * p,
//                          const unsigned char * num_subparts
// 						 double* ckpt_mem)
// {
// 	// this is the kernel entry point (workload wrapper)
// 	chain(total_subparts, max_dist_x, max_dist_y, bw, q_span, avg_qspan_scaled, a, f, p, num_subparts, ckpt_mem);
// }
/*
kernel __attribute__((reqd_work_group_size(1, 1, 1))) void chain1(long total_subparts,
                         int max_dist_x, int max_dist_y, int bw, int q_span, float avg_qspan_scaled, 
						 __global const ulong2 *restrict a,
                         __global int *restrict f, __global int *restrict p,
                         __global const unsigned char *restrict num_subparts)
{
	chain(total_subparts, max_dist_x, max_dist_y, bw, q_span, avg_qspan_scaled, a, f, p, num_subparts);
}

kernel __attribute__((reqd_work_group_size(1, 1, 1))) void chain2(long total_subparts,
                         int max_dist_x, int max_dist_y, int bw, int q_span, float avg_qspan_scaled, 
						 __global const ulong2 *restrict a,
                         __global int *restrict f, __global int *restrict p,
                         __global const unsigned char *restrict num_subparts)
{
	chain(total_subparts, max_dist_x, max_dist_y, bw, q_span, avg_qspan_scaled, a, f, p, num_subparts);
}

kernel __attribute__((reqd_work_group_size(1, 1, 1))) void chain3(long total_subparts,
                         int max_dist_x, int max_dist_y, int bw, int q_span, float avg_qspan_scaled, 
						 __global const ulong2 *restrict a,
                         __global int *restrict f, __global int *restrict p,
                         __global const unsigned char *restrict num_subparts)
{
	chain(total_subparts, max_dist_x, max_dist_y, bw, q_span, avg_qspan_scaled, a, f, p, num_subparts);
}
*/
