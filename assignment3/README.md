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

# Testing Your Code

You can use our JPL implementation on the CADE lab machines. The
compiler executable is in `/home/regehr/jplc/jplc`. Please test it on
the `gradient.jpl` program that we have provided. Your interaction
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

If this does not work, you may need to set some additional environment
variables, please see the settings at the bottom of
`/home/regehr/.bash_profile` on the CADE systems. Contact the
instructors on Discord if you are having trouble.

At this point you should view `gradient.png` and make sure it contains
a color gradient. You can do this either by downloading the png file
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
problems and solutions with you on Discord.

Each of your programs should be named after the function it mainly contains.
So, for example, `blur.jpl` would contain your blur function.

