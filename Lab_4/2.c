#include "stdio.h"

int main(int argc, char **argv){
    int a;
    scanf("%d", &a);
    if (a % 2 == 0){
        printf("%d \n", -a*(a+1)/2);
    }
    else{
        printf("%d \n", a*(a+1)/2);
    }
}