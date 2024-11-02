#include "stdio.h"

int main(){
    int s = 0;
    long n = 3363522457;
    for (long i = n; i > 0; i /= 10) {
        s += i % 10;
    }
    printf("%d\n", s);
    return 0;
}