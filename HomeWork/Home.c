#include <stdio.h>

unsigned long * create_array();
unsigned long * free_memory();
unsigned long * fill(unsigned long);
//int count_prost();
//int count_chet();
//void get_nechet();

int main(){
  unsigned long int n;
  scanf("%lu", &n);
  unsigned long *p = create_array();

  fill(n);

    for (int i = 0; i < n; i++)
    {
        printf("%ld\n",p[i]);
    }


  free_memory();
  return 0;

}