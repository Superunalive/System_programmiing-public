#include "stdio.h"

int main(int argc, char **argv){
    int a;
    int b;
    int c;
    scanf("%d", &a);
    // numbers lower than 10 don't have 2 digits
    // 10 has zero, division by zero is not acceptable
    for(int i = 11; i <= a; i++){
        b = i % 10;
        c = (i % 100 - b)/10;
        if (b != 0 && c != 0){
            if(i % b == 0 && i % c == 0){
                printf("%d \n", i);
            }
        }
    }
}