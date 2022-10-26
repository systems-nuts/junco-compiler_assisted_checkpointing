#include <stdint.h>
#include <stdlib.h>

int z = 3;
int y = 0;
void func(int num) {
    for (int i = 0; i < num; i ++) {
        if (i == z) {
            y = 1;
        }
    }
}

// int main() {
//     func(y);
// }
