#include <inttypes.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/errno.h>
#include <unistd.h>
#include <time.h>
#include <assert.h>
#include <math.h>

#define PNG_DEBUG 3
#include <png.h>

#include "runtime.h"

#ifdef NDEBUG
#error Please do not compile this file with NDEBUG defined
#endif

/*************** adapted from http://zarb.org/~gc/html/libpng.html *****************/

static void abort_(const char *s, ...) {
  printf("Fatal error: ");
  va_list args;
  va_start(args, s);
  vfprintf(stdout, s, args);
  fprintf(stdout, "\n");
  va_end(args);
  abort();
}

static void write_png_file(const char *file_name, int width, int height,
                           png_bytep *row_pointers) {
  png_byte bit_depth = 8;
  png_byte color_type = PNG_COLOR_TYPE_RGB_ALPHA;

  /* create file */
  FILE *fp = fopen(file_name, "wb");
  if (!fp)
    abort_("[write_png_file] File %s could not be opened for writing",
           file_name);

  /* initialize stuff */
  png_structp png_ptr =
      png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);

  if (!png_ptr)
    abort_("[write_png_file] png_create_write_struct failed");

  png_infop info_ptr = png_create_info_struct(png_ptr);
  if (!info_ptr)
    abort_("[write_png_file] png_create_info_struct failed");

  if (setjmp(png_jmpbuf(png_ptr)))
    abort_("[write_png_file] Error during init_io");

  png_init_io(png_ptr, fp);

  /* write header */
  if (setjmp(png_jmpbuf(png_ptr)))
    abort_("[write_png_file] Error during writing header");

  png_set_IHDR(png_ptr, info_ptr, width, height, bit_depth, color_type,
               PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_BASE,
               PNG_FILTER_TYPE_BASE);

  png_write_info(png_ptr, info_ptr);

  /* write bytes */
  if (setjmp(png_jmpbuf(png_ptr)))
    abort_("[write_png_file] Error during writing bytes");

  png_write_image(png_ptr, row_pointers);

  /* end write */
  if (setjmp(png_jmpbuf(png_ptr)))
    abort_("[write_png_file] Error during end of write");

  png_write_end(png_ptr, NULL);

  fclose(fp);
}

static void read_png_file(const char *file_name, uint64_t *_width, uint64_t *_height,
                          png_bytep **_row_pointers, int *alpha) {
  unsigned char header[8]; // 8 is the maximum size that can be checked

  /* open file and test for it being a png */
  FILE *fp = fopen(file_name, "rb");
  if (!fp)
    abort_("[read_png_file] File %s could not be opened for reading",
           file_name);
  fread(header, 1, 8, fp);
  if (png_sig_cmp(header, 0, 8))
    abort_("[read_png_file] File %s is not recognized as a PNG file",
           file_name);

  /* initialize stuff */
  png_structp png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);

  if (!png_ptr)
    abort_("[read_png_file] png_create_read_struct failed");

  png_infop info_ptr = png_create_info_struct(png_ptr);
  if (!info_ptr)
    abort_("[read_png_file] png_create_info_struct failed");

  if (setjmp(png_jmpbuf(png_ptr)))
    abort_("[read_png_file] Error during init_io");

  png_init_io(png_ptr, fp);
  png_set_sig_bytes(png_ptr, 8);

  png_read_info(png_ptr, info_ptr);

  int width = png_get_image_width(png_ptr, info_ptr);
  int height = png_get_image_height(png_ptr, info_ptr);
  png_byte color_type = png_get_color_type(png_ptr, info_ptr);
  png_byte bit_depth = png_get_bit_depth(png_ptr, info_ptr);

  if (bit_depth != 8)
    abort_("[read_png_file] Unsupported png type, color channels must be 8 bits");
  
  if (color_type == PNG_COLOR_TYPE_RGB) {
    *alpha = 0;
  } else if (color_type == PNG_COLOR_TYPE_RGB_ALPHA) {
    *alpha = 1;
  } else {
    printf("got color_type = %d\n", color_type);
    abort_("[read_png_file] Unsupported png type, must be SRBG or SRGBA");
  }

  int number_of_passes = png_set_interlace_handling(png_ptr);
  png_read_update_info(png_ptr, info_ptr);

  /* read file */
  if (setjmp(png_jmpbuf(png_ptr)))
    abort_("[read_png_file] Error during read_image");

  png_bytep *row_pointers = (png_bytep *)malloc(sizeof(png_bytep) * height);
  for (int y = 0; y < height; y++)
    row_pointers[y] = (png_byte *)malloc(png_get_rowbytes(png_ptr, info_ptr));

  png_read_image(png_ptr, row_pointers);

  fclose(fp);

  *_width = width;
  *_height = height;
  *_row_pointers = row_pointers;
}

/************* end adapted from http://zarb.org/~gc/html/libpng.html *************/

struct jpl_pixel {
  double r, g, b, a;
};

static int dto8(double d) {
  if (!isfinite(d))
    return 0;
  d *= 256;
  if (d > 255)
    d = 255;
  if (d < 0)
    d = 0;
  return (int)d;
}

static double _8tod(int c) {
  assert(c >= 0 && c < 256);
  return c / 255.0;
}

#define INDX(x, y) ((y * W) + x)

void _readPNG(int64_t *_H, int64_t *_W, double **_data, const char *fn) {
  uint64_t W, H;
  png_bytep *row_pointers;
  int alpha;
  read_png_file(fn, &W, &H, &row_pointers, &alpha);

  struct jpl_pixel *data = malloc(sizeof(struct jpl_pixel) * W * H);

  int pixel_size;
  if (alpha) {
    pixel_size = PNG_IMAGE_PIXEL_SIZE(PNG_FORMAT_RGBA);
    assert(pixel_size == 4);
  } else {
    pixel_size = PNG_IMAGE_PIXEL_SIZE(PNG_FORMAT_RGB);
    assert(pixel_size == 3);
  }
  
  for (int y = 0; y < H; y++) {
    png_byte *row = row_pointers[y];
    for (int x = 0; x < W; x++) {
      png_byte *ptr = &(row[x * pixel_size]);
      data[INDX(x,y)].r = _8tod(ptr[0]);
      data[INDX(x,y)].g = _8tod(ptr[1]);
      data[INDX(x,y)].b = _8tod(ptr[2]);
      data[INDX(x,y)].a = alpha ? _8tod(ptr[3]) : 1.0;
    }
  }

  for (int y = 0; y < H; y++)
    free(row_pointers[y]);

  *_W = W;
  *_H = H;
  *_data = (double *)data;
}

void _writePNG(int64_t H, int64_t W, double *data, const char *fn) {
  struct jpl_pixel *pp = (struct jpl_pixel *)data;

  png_bytep row_pointers[H];
  int pixel_size = PNG_IMAGE_PIXEL_SIZE(PNG_FORMAT_RGBA);
  assert(pixel_size == 4);

  for (int y = 0; y < H; y++) {
    png_byte *row = malloc(W * pixel_size);
    row_pointers[y] = row;
    for (int x = 0; x < W; x++) {
      png_byte *ptr = &(row[x * pixel_size]);
      ptr[0] = dto8((pp + INDX(x, y))->r);
      ptr[1] = dto8((pp + INDX(x, y))->g);
      ptr[2] = dto8((pp + INDX(x, y))->b);
      ptr[3] = dto8((pp + INDX(x, y))->a);
    }
  }

  write_png_file(fn, W, H, row_pointers);

  for (int y = 0; y < H; y++)
    free(row_pointers[y]);
}
