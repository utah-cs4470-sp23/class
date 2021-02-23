# Assignment 3: Writing some JPL

For this assignment you will implement some short JPL programs. In
each program, you will implement one of the functions specified below,
and also some code that calls the function so that you (and we) can
check that it works.

In JPL, the `pict` type is a rank-2 array of pixels, where a pixel is
a tuple containing four floats: `{ red, blue, green, alpha }`. The
four values in a pixel represent the intensity of that pixel in the
red, blue, green, and alpha channels. Each color channel ranges from
0.0 (none of that color) to 1.0 (maximum intensity of that color).
The alpha channel ranges from 0.0 (totally transparent) to 1.0
(totally opaque). For this assignment, you can always use 1.0 for the
alpha channel.

In JPL, a pixel that has values { 0., 1., 0., 1. } is maximally green,
a pixel with values { 0., 0., 0., 1. } is black, and a pixel with
values { 1., 1., 1., 1. } is pure white.

If you want to play around with RGB values a bit, the [Google color
picker](https://www.google.com/search?q=color+picker) is a good place
to do that. You should be looking at the RGB values at the left, but
keep in mind that these are showing intensity on a scale of 0 to 255
whereas JPL uses a scale from 0.0 to 1.0.

Here are the functions that you should implement.

1. sub_ints(int, int) : int

Return the difference of the arguments. In other words,
`sub_ints(10, 3)` should return 7.

Your test code should use the `show` command to show the result
of subtracting 1 from 1000000000.

2. sub_floats(float, float) : float

Return the difference of the arguments. In other words,
`sub_floats(10., 3.)` should return 7.0.

Your test code should use the `show` command to show the result
of subtracting 0.1 from 1000000000.0.

3. red(int, int) : pict

Given a width and a height, create a completely red image of that
size.

Your test code should create an 800x600 image and write it to `red.png`.

2. invert(pict) : pict

This function inverts the colors in an image. You can do this by
subtracting the R, G, and B channels of the input image from 1.0.  You
should leave the alpha channel as 1.0.

Your test code should load `sample.png` and write the inverted version
as `sample-inverted.png`.

3. circle(float, float) : pict

This function draws a white circle in the center of an 800x600 image.
The first argument is the radius of the circle (in pixels) and the
second is the thickness of the white line (also in pixels).

Your test code should call circle(400, 10) and write the resulting
image to `circle.png`.

6. has_size(pict, int, int) : bool

`has_size(img, 100, 90)` returns true if `img` has width 100 and
height 90, and false otherwise.

Your test code should load `sample.png` and assert that it `has_size`
800x600.

7. sepia(pict) : pict

8. blur(pict) : pict

Blurs the argument image. To do this, you should make each pixel value
of the output image the average of a 3x3 pixel area of the input image
centered at the output pixel coordinates. Edge cases must be treated
separately. For example, the red channel of teh pixel at (0,0) of the
output image should have its pixel values computed by average of the
red values of the pixels in the input image at (0,0), (0,1), (1,0),
and (1,1).

Your test program should blur `sample.png` and write the blurred
image to `sample-blurry.png`.

8. resize(pict, int, int) : pict

This function scales an image to a new width and height. (WRITE ME PAVEL)

10. crop(pict, int, int, int, int) : pict

(WRITE ME PAVEL)

# HANDIN

This assignment has no checkin component, but we are happy to discuss
problems and solutions with you on Discord.

Test your code using (WRITE ME)

Each of your programs should be named after the function it mainly contains,
so for example, `blur.jpl` would contain your blur function.

