#include <stdio.h>

const int X = 17;
const int Y = 23;
const int Z = 31;

int main() {
  int sum = 0;
  
  int i = 0;
  int j = 0;
  int k = 0;

  // This is a loop:
  // for (int i = 0; i < X; i++) {
  // for (int j = 0; j < Y; j++) {
  // for (int k = 0; k < Z; k++) {
  start:

      // This part is the loop body
      sum++;

  k++;
  if (k < Z) goto start;
  k = 0;
  j++;
  if (j < Y) goto start;
  j = 0;
  i++;
  if (i < X) goto start;
  // }
  // }
  // }
  
  // This should print X * Y * Z = 12121
  printf("%d\n", sum);
  return 0;
}
