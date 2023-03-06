#include <stdio.h>
#include <stdlib.h>
#include <algorithm>    // std::min

void checkpoint() {}


/*#FUNCTION_DEF#*/
/* FUNC blur : ARGS */
int foo(int* ckpt_mem) {
  int k = 0;
  int arr[4] = {0,1,2, 3};
  for (int i = 0; i < 3; i++)
  {
    arr[i] = 1 + i*2;
    k = std::min(k, arr[i]);
    checkpoint();
  }
  return k;
}

int main() {
  int ckpt_mem[10]; 
  foo(ckpt_mem);
}