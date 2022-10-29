#include <stdint.h>
#include <stdlib.h>

void func_A();
void func_B();
void func_C();
void func_D();

int k = 0;
int x = 0;
int y = 0;

void func_A() {
    k = 3;
    func_B();
}

void func_B() {
    x = k;
    func_C();
}

void func_C() {
    y = k;
    func_D();
}

void func_D() {
    k = 4;
}

int main() {
    func_A();
}



