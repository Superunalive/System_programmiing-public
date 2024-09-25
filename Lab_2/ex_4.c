#include "stdio.h"

int main(){
    char s = 0;
    for (long n = 3363522457; n; n /= 10) {
        s += n % 10;
    }
    printf("%d\n", s);
    return 0;
}