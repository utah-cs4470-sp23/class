#include <stdio.h>

const int X = 2;
const int Y = 3;
const int Z = 5;

int main() {
  int i = 0;
  int j = 0;
  int k = 0;

  // This is a loop:
  // for (int i = 0; i < X; i++) {
  // for (int j = 0; j < Y; j++) {
  // for (int k = 0; k < Z; k++) {
  start:

  // This part is the loop body
  printf("i = %d, j = %d, k = %d\n", i, j, k);

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
  
  // This should loop X * Y * Z = 30 times
  return 0;
}
