#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

int z = 44;
int arr[10] = {};

void func(int offset) {
    int arrLen = sizeof(arr)/sizeof(int);
    for (int i = 0; i < arrLen; i ++) {
        if (i == offset) {
            arr[i] = z;
        } else {
            arr[i] = i;
        }
    }
}

int main() {
  // get user input
  int input;
  scanf("%d", &input);

  int offset = 0;
  if (input == 1) {
    offset = 4;
  }

  func(offset);
}