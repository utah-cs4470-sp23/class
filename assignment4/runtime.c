#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include "runtime.h"

int main();

const int PB = 1;
const int MAX = 1 << (8 * PB);

struct {
  size_t i;
  uint8_t data[MAX];
} mem;

uint8_t getmem(size_t amt) {
  if (mem.i + amt < MAX) {
    mem.i += amt;
    return mem.i - amt;
  } else {
    fprintf(stderr, "[builtin show] Type too complex, cannot parse");
    exit(127);
  }
}

void tprintf(const char *fmt, ...) {
  int bad = 0;
  va_list args;
  va_start(args, fmt);
  if (vprintf(fmt, args) < 0) bad = 1;
  va_end(args);
  if (bad) {
    fprintf(stderr, "[builtin show] printf failed, aborting");
    exit(127); 
  }
}

// Types are:
static const uint8_t BOOL = 251;
static const uint8_t INT = 252;
static const uint8_t FLOAT = 253;
static const uint8_t ARRAY = 254;
static const uint8_t NDARRAY = 255;

uint8_t parse_type(char *type_str, char **new_type_str);
size_t size_type(uint8_t t);
void show_type(uint8_t t, void *data);

uint8_t parse_bool_type(char *type_str, char **new_type_str) {
  char *orig_type_str = type_str;
  if (*type_str++ != 'b') goto fail;
  if (*type_str++ != 'o') goto fail;
  if (*type_str++ != 'o') goto fail;
  if (*type_str++ != 'l') goto fail;
  uint8_t t = getmem(1);
  mem.data[t] = BOOL;
  *new_type_str = type_str;
  return t;
  fail:
  fprintf(stderr, "[builtin show] Could not parse boolean type in %s", orig_type_str);
  exit(127);
}

uint8_t parse_int_type(char *type_str, char **new_type_str) {
  char *orig_type_str = type_str;
  if (*type_str++ != 'i') goto fail;
  if (*type_str++ != 'n') goto fail;
  if (*type_str++ != 't') goto fail;
  uint8_t t = getmem(1);
  mem.data[t] = INT;
  *new_type_str = type_str;
  return t;
  fail:
  fprintf(stderr, "[builtin show] Could not parse integer type in %s", orig_type_str);
  exit(127);
}

uint8_t parse_float_type(char *type_str, char **new_type_str) {
  char *orig_type_str = type_str;
  if (*type_str++ != 'f') goto fail;
  if (*type_str++ != 'l') goto fail;
  if (*type_str++ != 'o') goto fail;
  if (*type_str++ != 'a') goto fail;
  if (*type_str++ != 't') goto fail;
  uint8_t t = getmem(1);
  mem.data[t] = FLOAT;
  *new_type_str = type_str;
  return t;
  fail:
  fprintf(stderr, "[builtin show] Could not parse floating type in %s", orig_type_str);
  exit(127);
}

uint8_t parse_tuple_type(char *type_str, char **new_type_str) {
  uint8_t tuple_mem[256];
  char *orig_type_str = type_str;
  if (*type_str++ != '{') goto fail;
  while (*type_str == ' ') type_str++;
  size_t i = 0;
  if (*type_str != '}') {
    tuple_mem[i++] = parse_type(type_str, &type_str);
    while (*type_str == ' ') type_str++;
    while (*type_str != '}') {
      if (*type_str++ != ',') goto fail;
      while (*type_str == ' ') type_str++;
      tuple_mem[i++] = parse_type(type_str, &type_str);
      if (i >= BOOL) {
          fprintf(stderr, "[builtin show] Tuples with %zu or more fields not supported", i);
          exit(127);
      }
    }
  }
  type_str++;
  uint8_t t, p;
  p = t = getmem(1 + i);
  mem.data[t++] = i;
  for (int j = 0; j < i; j++) {
    mem.data[t++] = tuple_mem[j];
  }
  *new_type_str = type_str;
  return p;
  fail:
  fprintf(stderr, "[builtin show] Could not parse tuple type in %s", orig_type_str);
  exit(127);
}

uint8_t parse_type(char *type_str, char **new_type_str) {
  char *orig_type_str = type_str;
  while (*type_str == ' ') type_str++;

  uint8_t t = 0;
  switch (*type_str) {
  case '{':
    t = parse_tuple_type(type_str, &type_str);
    break;
  case 'i':
    t = parse_int_type(type_str, &type_str);
    break;
  case 'f':
    t = parse_float_type(type_str, &type_str);
    break;
  case 'b':
    t = parse_bool_type(type_str, &type_str);
    break;
  default:
    fprintf(stderr, "[builtin show] Could not parse type in %s", type_str);
    exit(127);
  }

  uint8_t rank;
  while (1) {
    switch (*type_str) {
    case '[':
      rank = 1;
      type_str++;
      while (*type_str == ' ') type_str++;
      while (*type_str == ',') {
        if (rank >= 255) {
          fprintf(stderr, "[builtin show] Ranks above 255 not supported");
          exit(127);
        }
        rank += 1;
        type_str++;
        while (*type_str == ' ') type_str++;
      }
      while (*type_str == ' ') type_str++;
      if (*type_str != ']') {
        fprintf(stderr, "[builtin show] Could not parse type in %s", orig_type_str);
        exit(127);
      }
      type_str++;
      uint8_t p2, p;
      if (rank == 1) {
        p2 = p = getmem(2);
        mem.data[p++] = ARRAY;
        mem.data[p++] = t;
      } else {
        p2 = p = getmem(3);
        mem.data[p++] = NDARRAY;
        mem.data[p++] = rank;
        mem.data[p++] = t;
      }
      t = p2;
      continue;
    case ' ':
      type_str++;
      continue;
    default:
      *new_type_str = type_str;
      return t;
    };
  }
}

size_t size_type(uint8_t t) {
  int rank, fields, size;
  switch (mem.data[t]) {
  case BOOL:
    return sizeof(int);
  case INT:
    return sizeof(int64_t);
  case FLOAT:
    return sizeof(double);
  case NDARRAY:
    return sizeof(int64_t) + sizeof(void *);
  case ARRAY:
    rank = (int) mem.data[t + 1];
    return rank * sizeof(int64_t) + sizeof(void *);
  default:
    fields = (int) mem.data[t];
    size = 0;
    for (int i = 0; i < fields; i++) {
      size += size_type(mem.data[t + i]);
    }
    return size;
  }
}

void show_array(uint8_t subtype, int rank, uint64_t *data2) {
  void *subdata = (void*)data2[rank];
  uint64_t size = 1;
  for (int i = 0; i < rank; i++) {
    uint64_t dim = data2[i];
    if (__builtin_mul_overflow(size, dim, &size)) {
      fprintf(stderr, "[builtin show] Overflow when computing total size of array");
      exit(127);
    }
  }

  size_t step = size_type(subtype);
  tprintf("[");
  for (int64_t i = 0; i < size; i++) {
    show_type(subtype, subdata + i * step);
    int64_t j = i + 1;
    int rankstep = 0;
    while (j % data2[rank - rankstep - 1] == 0) {
      j /= data2[rank - rankstep - 1];
      rankstep++;
    }
    if (i + 1 < size) {
      if (rankstep == 0) {
        tprintf(", ");
      } else {
        for (j = 0; j < rankstep; j++) tprintf(";");
        tprintf(" ");
      }
    }
  }
  tprintf("]");
}

void show_type(uint8_t t, void *data) {
  switch (mem.data[t]) {
  case BOOL:
    if (*(int32_t*)data) {
      tprintf("true");
    } else {
      tprintf("false");
    }
    return;
  case INT:
    tprintf("%lld", *(int64_t*)data);
    return;
  case FLOAT:
    tprintf("%f", *(double*)data);
    return;
  case ARRAY: {
    show_array(mem.data[t + 1], 1, data);
    return;
  }
  case NDARRAY: {
    show_array(mem.data[t + 2], (int) mem.data[t + 1], data);
    return;
  }
  default: {
    int fields = (int) mem.data[t];
    int offset = 0;
    tprintf("{");
    for (int i = 0; i < fields; i++) {
      show_type(mem.data[t + 1 + i], data + offset);
      offset += size_type(mem.data[t + 1 + i]);
      if (i + 1 != fields) {
        tprintf(", ");
      }
    }
    tprintf("}");
    return;
  }
  }
}

struct pict {
    int64_t rows;
    int64_t cols;
    double *data;
};

int32_t show(char *type_str, void *data) {
  /* We expect that the second argument is a pointer to data, even if
     that data is an integer or something like that. */
  if (strnlen(type_str, 256) == 256) {
    fprintf(stderr, "[builtin show] Type string is too long in %s", type_str);
    exit(127);
  }
  mem.i = 0; // Allocate memory
  char *orig_type_str = type_str;
  uint8_t t = parse_type(type_str, &type_str);
  while (*type_str == ' ') type_str++;
  if (*type_str != '\0') {
    fprintf(stderr, "[builtin show] Cannnot parse type string in %s", orig_type_str);
    exit(127);
  }
  show_type(t, data);
  return 1;
}

int32_t _show(char *type_str, void *data) {
  return show(type_str, data);
}

void fail_assertion(char *s) {
  printf("[abort] %s", s);
  exit(1);
}

void _fail_assertion(char *s) {
  return fail_assertion(s);
}

void print(char *s) {
  printf("%s", s);
}

void _print(char *s) {
  return print(s);
}

double get_time(void) {
  clock_t c = clock();
  return ((double) c) / CLOCKS_PER_SEC;
}

double _get_time(void) {
  return get_time();
}

int64_t sub_ints(int64_t a, int64_t b) {
  return a - b;
}

int64_t _sub_ints(int64_t a, int64_t b) {
  return sub_ints(a, b);
}

double sub_floats(double a, double b) {
  return a - b;
}

double _sub_floats(double a, double b) {
  return sub_floats(a, b);
}

int32_t has_size(struct pict input, int64_t rows, int64_t cols) {
  return input.rows == rows && input.cols == cols;
}

int32_t _has_size(struct pict input, int64_t rows, int64_t cols) {
  return has_size(input, rows, cols);
}

#define INDX(p, x, y, chan) p.data[(4 * (((x) * (p).cols) + (y)) + (chan))]

// sepia(pict) : pict
struct pict sepia(struct pict p) {
  struct pict ret;
  ret.rows = p.rows;
  ret.cols = p.cols;
  ret.data = malloc(p.rows * p.cols * 4 * sizeof(double));
  if (!ret.data)
    fail_assertion("malloc failed\n");
  for (long i=0; i<p.rows; ++i) {
    for (long j=0; j<p.cols; ++j) {
      double oldR = INDX(p, i, j, 0);
      double oldG = INDX(p, i, j, 1);
      double oldB = INDX(p, i, j, 2);
      INDX(ret, i, j, 0) = 0.393 * oldR + 0.769 * oldG + 0.189 * oldB;
      INDX(ret, i, j, 1) = 0.349 * oldR + 0.686 * oldG + 0.168 * oldB;
      INDX(ret, i, j, 2) = 0.272 * oldR + 0.534 * oldG + 0.131 * oldB;
      INDX(ret, i, j, 3) = 1.0;
    }
  }
  return ret;
}
struct pict _sepia(struct pict p) {
  return sepia(p);
}

// blur(pict, float) : pict
struct pict blur(struct pict p, double f) {
  if (f <= 0.0)
    fail_assertion("Blur radius must be positive\n");

  int64_t sides = (int) fmin(3.0 * f + 0.5, p.rows < p.cols ? p.rows : p.cols);
  int64_t size = 2 * sides + 1;
  double *filter = malloc(size * size * sizeof(double));
  if (!filter)
    fail_assertion("malloc failed\n");

  double denom = 1.0 / (2.0 * M_PI * f * f);
  double edenom = -1.0 / (2.0 * f * f);
  for (long i = -sides; i <= sides; i++) {
    for (long j = -sides; j <= sides; j++) {
      double r = i * i + j * j;
      filter[(i + sides) * size + j + sides] = denom * exp(r * edenom);
    }
  }

  struct pict ret;
  ret.rows = p.rows;
  ret.cols = p.cols;
  ret.data = malloc(p.rows * p.cols * 4 * sizeof(double));
  if (!ret.data)
    fail_assertion("malloc failed\n");
  for (long i = 0; i < p.rows; i++) {
    for (long j = 0; j < p.cols; j++) {
      double r = 0.0;
      double g = 0.0;
      double b = 0.0;
      double total = 0.0;
      for (long n = i - sides; n <= i + sides; n++) {
        if (n < 0) continue;
        if (n >= p.rows) continue;
        for (long m = j - sides; m <= j + sides; m++) {
          if (m < 0) continue;
          if (m >= p.cols) continue;
          double scale = filter[size * (n - i + sides) + (m - j + sides)];
          total += scale;
          r += p.data[4 * (n * p.cols + m) + 0] * scale;
          g += p.data[4 * (n * p.cols + m) + 1] * scale;
          b += p.data[4 * (n * p.cols + m) + 2] * scale;
        }
      }
      ret.data[4 * (i * p.cols + j) + 0] = r / total;
      ret.data[4 * (i * p.cols + j) + 1] = g / total;
      ret.data[4 * (i * p.cols + j) + 2] = b / total;
      ret.data[4 * (i * p.cols + j) + 3] = 1.0;
    }
  }
  return ret;
}

struct pict _blur(struct pict p, double f) {
  return blur(p, f);
}

// resize(pict, int, int) : pict
struct pict resize(struct pict p, int x, int y) {
  if (x <= 0 || y <= 0)
    fail_assertion("Must resize to a positive size\n");
  struct pict ret;
  ret.rows = x;
  ret.cols = y;
  ret.data = malloc(x * y * 4 * sizeof(double));
  if (!ret.data)
    fail_assertion("malloc failed\n");
  for (long i=0; i<x; ++i) {
    for (long j=0; j<y; ++j) {
      double oldi = (i + 0.5) * p.rows / ((double) x) - 0.5;
      double oldj = (j + 0.5) * p.rows / ((double) x) - 0.5;
      
      int64_t oii, oji;
      double oif, ojf;
      oii = (int64_t) oldi;
      oji = (int64_t) oldj;
      oif = oldi - (double) oii;
      ojf = oldj - (double) oji;

      double r, g, b, a;
      r = (1.0 - oif) * (1.0 - ojf) * INDX(p, oii, oji, 0) \
        + (oif > 0.0 ? (0.0 + oif) * (1.0 - ojf) * INDX(p, oii + 1, oji, 0) : 0.0) \
        + (ojf > 0.0 ? (1.0 - oif) * (0.0 + ojf) * INDX(p, oii, oji + 1, 0) : 0.0) \
        + (oif * ojf > 0.0 ? (0.0 + oif) * (0.0 + ojf) * INDX(p, oii + 1, oji + 1, 0) : 0.0);
      g = (1.0 - oif) * (1.0 - ojf) * INDX(p, oii, oji, 1) \
        + (oif > 0.0 ? (0.0 + oif) * (1.0 - ojf) * INDX(p, oii + 1, oji, 1) : 0.0) \
        + (ojf > 0.0 ? (1.0 - oif) * (0.0 + ojf) * INDX(p, oii, oji + 1, 1) : 0.0) \
        + (oif * ojf > 0.0 ? (0.0 + oif) * (0.0 + ojf) * INDX(p, oii + 1, oji + 1, 1) : 0.0);
      b = (1.0 - oif) * (1.0 - ojf) * INDX(p, oii, oji, 2) \
        + (oif > 0.0 ? (0.0 + oif) * (1.0 - ojf) * INDX(p, oii + 1, oji, 2) : 0.0) \
        + (ojf > 0.0 ? (1.0 - oif) * (0.0 + ojf) * INDX(p, oii, oji + 1, 2) : 0.0) \
        + (oif * ojf > 0.0 ? (0.0 + oif) * (0.0 + ojf) * INDX(p, oii + 1, oji + 1, 2) : 0.0);
      a = 1.0;

      INDX(ret, i, j, 0) = r;
      INDX(ret, i, j, 1) = g;
      INDX(ret, i, j, 2) = b;
      INDX(ret, i, j, 3) = a;
    }
  }
  return ret;
}

struct pict _resize(struct pict p, int x, int y) {
  return resize(p, x, y);
}

// crop(pict, int, int, int, int) : pict
struct pict crop(struct pict p, int x1, int y1, int x2, int y2) {
  struct pict ret;
  ret.rows = y2 - y1;
  ret.cols = x2 - x1;
  ret.data = malloc(ret.rows * ret.cols * 4 * sizeof(double));
  if (!ret.data)
    fail_assertion("malloc failed\n");
  for (long i=0; i<ret.cols; ++i) {
    for (long j=0; j<ret.rows; ++j) {
      long ii = i + y1;
      long jj = j + x1;
      INDX(ret, i, j, 0) = INDX(p, ii, jj, 0);
      INDX(ret, i, j, 1) = INDX(p, ii, jj, 1);
      INDX(ret, i, j, 2) = INDX(p, ii, jj, 2);
      INDX(ret, i, j, 3) = INDX(p, ii, jj, 3);
    }
  }
  return ret;
}
struct pict _crop(struct pict p, int x1, int y1, int x2, int y2) {
  return crop(p, x1, y1, x2, y2);
}


struct pict read_image(char *filename) {
  struct pict out;
  _readPNG(&out.rows, &out.cols, &out.data, filename);
  return out;
}

struct pict _read_image(char *filename) {
  return read_image(filename);
}

void write_image(struct pict input, char *filename) {
  _writePNG(input.rows, input.cols, input.data, filename);
}

void _write_image(struct pict input, char *filename) {
  write_image(input, filename);
}



// Test code below

#ifdef TEST_RUNTIME
void print_uint8_ts(char *s, uint8_t where) {
  printf("%s = [", s);
  for (uint8_t j = 0; j < mem.i; j++) {
    if (j == where) printf("(*)");
    printf("%d: %i", j, mem.data[j]);
    if (j + 1 < mem.i) {
      printf(", ");
    }
  }
  printf("]\n");
}
 
#define TEST_PARSE(S) mem.i = 0; printf("[%lu] ", strlen(S)); print_uint8_ts(S, parse_type(S, &junk));

int32_t boolv = 1;
int64_t intv = 12;
double floatv = 123.456;
int64_t int5[] = {0, 1, 2, 3, 4};
struct {
  int64_t len;
  int64_t *data;
} intarrb = {5, int5};
int64_t int6[] = {7, 8, 9, 10, 11, 12};
struct {
  int64_t len1;
  int64_t len2;
  int64_t *data;
} intarrarrb = {2, 3, int6};
struct {
  int64_t i;
  double f;
} intfloatv = { 37, 412.718 };
 
#define TEST_SHOW(S, B) mem.i = 0; printf("%s: ", S); show(S, &B); printf("\n");

int main() {
  char *junk;
  TEST_PARSE("bool");
  TEST_PARSE("int");
  TEST_PARSE("float");
  TEST_PARSE("int[]");
  TEST_PARSE("int[,]");
  TEST_PARSE("{int,float}");
  TEST_PARSE("{int,{float}}");
  TEST_PARSE("{int[],{float, int}[,,]}[,,][,,,,,]");
  TEST_PARSE("{}[,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,]");
  TEST_PARSE("{{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}}")
  TEST_PARSE("{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}")

  TEST_SHOW("bool", boolv);
  TEST_SHOW("int", intv);
  TEST_SHOW("float", floatv);
  TEST_SHOW("int[]", intarrb);
  TEST_SHOW("int[,]", intarrarrb);
  // Note that the same pointer can have multiple types!
  TEST_SHOW("{int,float}", intfloatv);
  TEST_SHOW("{int,{float}}", intfloatv);
  TEST_SHOW("{int,{{},{{}}},{float}}", intfloatv);
}
#endif
