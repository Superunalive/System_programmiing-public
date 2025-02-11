#include <stdio.h>

unsigned long * create_array(unsigned long);
unsigned long * free_memory();
unsigned long * fill();


int main(){
  unsigned long int n;
  scanf("%lu", &n);
  unsigned long *p = create_array(n);

  fill();
    printf("Список элементов массива:\n");
    for (int i = 0; i < n; i++)
    {
        printf("%ld\n",p[i]);
    }



  free_memory();
  return 0;

}