#include "stdio.h"

int main(int argc, char **argv){
    int a = atoi(argv[1]);
    int b = atoi(argv[2]);
    int c = atoi(argv[3]);
    printf((((a - c) * b) / c) * a);
}