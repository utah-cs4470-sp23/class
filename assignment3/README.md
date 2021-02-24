# Assignment 3: Writing some JPL

For this assignment you will implement some short JPL programs. In
each program, you will implement one of the functions specified below,
and also some code that calls the function so that you (and we) can
check that it works.

## Images in JPL

In JPL, the `pict` type is a rank-2 array of pixels, where a pixel is
a tuple containing four floats: `{ red, blue, green, alpha }`. The
four values in a pixel represent the intensity of that pixel in the
red, blue, green, and alpha channels. Each color channel ranges from
0.0 (none of that color) to 1.0 (maximum intensity of that color). The
alpha channel ranges from 0.0 (totally transparent) to 1.0 (totally
opaque).

For example, the pixel value `{ 1., 0., 0., 1. }` is an opaque red
color, while `{ 1., 1., 0., 0.5 }` is a semi-transparent magenta. The
pixel value `{ 0., 1., 0., 1. }` is pure green, `{ 0., 0., 0., 1. }`
is pure black, and `{ 1., 1., 1., 1. }` is pure white. For this
assignment, we won't be dealing with transparency, so you can always
use `1.0` for the alpha channel.

You can play around with the [Google color picker][color-picker] to
look up RGB colors. The RGB values are on the left, though keep in
mind that these are using a scale of 0 to 255 whereas JPL uses a scale
from 0.0 to 1.0, so you'll have to do a bit of math to convert between
the two representations.

[color-picker]: https://www.google.com/search?q=color+picker

In JPL images, the first dimension is the row and the second dimension
is the height. So an image is normally passed like this: `img[H, W]`.
But when we write the size of an image below we write `WxH`. Don't get
these mixed up.

## Your assignment

Here are the functions that you should implement.

    sub_ints(int, int) : int

Return the difference of the arguments. In other words, `sub_ints(10,
3)` should return 7.

Your test code should use the `show` command to show the result of
subtracting 1 from 1000000000 (one billion).

    sub_floats(float, float) : float

Return the difference of the arguments. In other words,
`sub_floats(10., 3.)` should return 7.0.

Your test code should use the `show` command to show the result of
subtracting 0.1 from 1000000000.0 (one billion).

    red(int, int) : pict

Given a width and a height, create an image of that size that is
completely red.

Your test code should create an 800x600 image and write it to
`red.png`.

    invert(pict) : pict

This function inverts the colors in an image. You can do this by
subtracting the R, G, and B channels of the input image from 1.0. You
should leave the alpha channel unchanged at 1.0.

Your test code should load `sample.png` and write the inverted version
as `sample-inverted.png`.

    circle(float, float) : pict

This function draws a white, unfilled circle in the center of an
800x600 image. The first argument is the radius of the circle (in
pixels) and the second is the thickness of the white line (also in
pixels).

Your test code should call `circle(400, 10)` and write the resulting
image to `circle.png`.

    has_size(pict, int, int) : bool

Tests if an image has a given size. `has_size(img, 100, 90)` returns
true if `img` has width 100 and height 90, and false otherwise.

Your test code should load `sample.png` and assert that it `has_size`
800x600.

    sepia(pict) : pict

Converts a photo to [sepia-tone][sepia], like old-timey photos are. To
do so, take any RGB pixel and covert it to a new RGB pixel using this
formula:

    new R = 0.393 * old R + 0.769 * old G + 0.189 * old B
    new G = 0.349 * old R + 0.686 * old G + 0.168 * old B
    new B = 0.272 * old R + 0.534 * old G + 0.131 * old B

Be careful because sometimes this formula produces values bigger
than 1. That is never legal in JPL and you must cap pixel values at 1.0

[sepia]: https://www.google.com/search?q=sepia+tone&tbm=isch

    blur(pict) : pict

Blurs the argument image. To do this, you should make each pixel value
of the output image the average of a 3x3 pixel area of the input image
centered at the output pixel coordinates. The edges of the image must
be treated as a special case. The red channel of the pixel at (0,0),
for example, should have its pixel values computed by average of the
red values of the four pixels in the input image at (0,0), (0,1),
(1,0), and (1,1). It can't be a full 3x3 square because five of those
pixels would be off-screen.

Your test program should blur `sample.png` and write the blurred image
to `sample-blurry.png`. Time the resulting code using the built-in
`time` command. Make sure that the timing includes all of the time
spent blurring, but does not include the time spent reading and
writing files.

    resize(pict, int, int) : pict

This function scales an image to a new width and height using linear
interpolation. Let's say the input image is `W`x`H` it's being resized
to `W2xH2`. That means ideally you'd like the output pixel at (`i`,
`j`) to correspond to the input pixel at (`i2 = i / W * W2`, `j2 = j /
W * W2`). But in general that isn't an integer coordinate; let's say
`i2 = i2_int + i2_frac` for the integer part `i2_int` and the
fractional part `i2_frac`, and similar for `j2`. Then you want to
value of the pixel to be the following weighted average:

      pixel @ (i2_int, j2_int) * (1 - i2_frac) * (1 - j2_frac)
    + pixel @ (i2_int + 1, j2_int) * i2_frac * (1 - j2_frac)
    + pixel @ (i2_int, j2_int + 1) * (1 - i2_frac) * j2_frac
    + pixel @ (i2_int + 1, j2_int + 1) * i2_frac * j2_frac

You can find [more details][bilin] online.

[bilin]: https://chao-ji.github.io/jekyll/update/2018/07/19/BilinearResize.html

Your test program should resize `sample.png` to have size 193x139
pixels, and write the results to `sample_small.png`.

    crop(pict, int, int, int, int) : pict

Given a picture, extracts a rectangle for it given the top left and
bottom right coordinates of the square. The top and left coordinates
must be treated inclusively, while the bottom and right coordinates
must be treated inclusively. For example, `crop(img, 10, 20, 100,
500)` should output an image of size `480x90`.

Your test program should extract the 200x100 rectangle at the center of
`sample.png` and write the resulting cropped image to
`sample-center.png`.

# Testing Your Code

You can use our JPL implementation on the CADE lab machines. The
compiler executable is in `/home/regehr/jplc/jplc`. Please test it on
the `gradient.jpl` program that we have provided in the same directory
as the markdown file that you are reading right now. Your interaction
with the compiler should look like this:

```
$ /home/regehr/jplc/jplc gradient.jpl 

Compilation succeeded
$ ./a.out 
[start timer]
[0.005576s]
wrote 800 x 600 png to 'gradient.png'
$ 
```

Note that a standard JPL program would not print this information, but
we have modified our compiler to make it easier for you to debug your
code.

If this does not work, you may need to set some additional environment
variables, please see the settings at the bottom of
`/home/regehr/.bash_profile` on the CADE systems. Contact the
instructors on Discord if you are having trouble.

The compiler we have provided is not supposed to crash, nor is it
supposed to generate executables that crash (recall that JPL is a
*safe* programming language). However, this compiler is very new and
it is not particularly well tested. If you suspect that you have run
into a compiler bug, please bring this up on the Discord and we'll try
to get it fixed. This compiler also does not produce great error
messages and we apologize in advance for that. (If you hate the error
messages that it produces, then hopefully this will motivate you to do
a better job in your own compiler!)

At this point you should view `gradient.png` and make sure it contains
a color gradient. You can do this either by downloading the PNG file
to your own machine, or you might also be able to use a remote display
program. This will only work from a machine that has an X windows
server installed (these are available for all common platforms, but
are usually not installed by default on Windows or Mac machines).

For example, if you have a Mac with XQuartz installed, or you are on a
Linux box, you can `ssh` to CADE with remote display enabled like this:

```
Johns-MacBook-Pro:jpl johnregehr$ ssh -Y regehr@lab2-3.eng.utah.edu
Warning: No xauth data; using fake authentication data for X11 forwarding.
Last login: Tue Feb 23 14:17:53 2021 from c-67-163-89-122.hsd1.ut.comcast.net

#################################################
#               Welcome to CADE                 #
#                                               #
#            No Scheduled Downtime              #
#################################################

[regehr@lab2-3 ~]$ display gradient.png 
```

At this point, after a delay, the image should show up on your local
machine in a windows.

# HANDIN

This assignment has no checkin component, but we are happy to discuss
problems and solutions with you on Discord. Please do not post full
solutions to individual problems in the Discord.

Each of your programs should be named after the function it mainly
contains. So, for example, `blur.jpl` would contain your blur
function and the corresponding test code.

Hand in 10 JPL files in a directory called `assignment3` in your
Github repo.
