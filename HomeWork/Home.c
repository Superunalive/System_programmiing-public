#include <stdio.h>
unsigned long * create_array(unsigned long size);
//unsigned long * free_memory();
void fill(unsigned long* array, unsigned long);
unsigned long add_to_end(unsigned long *array, unsigned long *size, unsigned long number);
unsigned long remove_from_beginning(unsigned long * array, unsigned long * size);
unsigned long count_numbers_ending_with_1(unsigned long * array, unsigned long size);
unsigned long get_odd_numbers_list(unsigned long * array, unsigned long size);

int main(){
  unsigned long int n;
  scanf("%lu", &n);
  unsigned long *p = create_array(n);
  fill(p, n);
  printf("Список элементов массива до изменений:\n");
  for (int i = 0; i < n; i++)
  {
      printf("%ld\n",p[i]);
  }
  unsigned long int a = 41;
  n = add_to_end(p, &n, a);
  n = remove_from_beginning(p, &n);
    printf("Список элементов массива:\n");
    for (int i = 0; i < n; i++)
    {
        printf("%ld\n",p[i]);
    }
  printf("Элементов, оканчивающихся на 1: %ld\n", count_numbers_ending_with_1(p, n));
  printf("Нечётные числа:\n");
  get_odd_numbers_list(p, n);
  //free_memory();
  return 0;

}