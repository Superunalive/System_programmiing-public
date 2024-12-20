#include "stdio.h"

int main(int argc, char **argv){
    int a;
    int ans = 0;
    scanf("%d", &a);
    for(int i = 1; i <= a; i++){
        if(i % 55 != 0){
            ans++;
        }
    }
    printf("%d \n", ans);
}