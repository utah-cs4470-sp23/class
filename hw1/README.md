Assignment 1: Writing some JPL
==============================

For this assignment you will implement some short JPL programs. In
each program, you will implement one of the functions specified below,
and also some code that calls the function so that you (and we) can
check that it works.

For example, if your assignment were to write a function `four` that
returns the integer four, and the test code were to `show` a call to
that function, a solution could look like this:

```
fn four() : int {
    return 4
}

show four()
```

In case it is helpful, we are providing an [example JPL
program](gradient.jpl), which generates a colorful gradient and writes
it to `gradient.png`. You can use this example program to make sure
you have the JPL compiler working correctly.

## Images in JPL

In this assignment we'll refer to a `pict` type: a rank-2 array of
pixels, where a pixel is a tuple containing four floats: `{ red,
green, blue, alpha }`. In JPL code you should use the explicit
version of this type, `{float,float,float,float}[,]`, or perhaps use a
`type` command to introduce the `pict` shorthand yourself.

The four values in a pixel represent the intensity of that pixel in
the red, green, blue, and alpha channels. Each color channel ranges
from 0.0 (none of that color) to 1.0 (maximum intensity of that
color). The alpha channel ranges from 0.0 (totally transparent) to 1.0
(totally opaque).

For example, the pixel value `{ 1., 0., 0., 1. }` is an opaque red
color, while `{ 1., 1., 0., 0.5 }` is a semi-transparent yellow. The
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
is the column. So an image is normally passed like this: `img[H, W]`.
But when we write the size of an image below we write `WxH`. Don't get
these mixed up.

## Your assignment

    subtract(float, float) : float

Return the difference of the arguments. In other words,
`subtract(10., 3.)` should return 7.0.

Your test code should use the `show` command to show the result of
subtracting 0.1 from 1000000000.0 (one billion).

    red(int, int) : pict

Given a width and a height, create an image of that size that is
completely red.

Your test code should create an 800x600 image and write it to
`red.png`.

    circle(float, float) : pict

This function draws a white, unfilled circle in the center of a black
800x600 image. The first argument is the radius of the circle (in
pixels) and the second is the thickness of the white line (also in
pixels).

Your test code should call `circle(400.0, 10.0)` and write the
resulting image to `circle.png`.

    invert(pict) : pict

This function inverts the colors in an image. You can do this by
subtracting the R, G, and B channels of the input image from 1.0. You
should leave the alpha channel unchanged at 1.0.

Your test code should load `sample.png` and write the inverted version
as `sample-inverted.png`.

    sepia(pict) : pict

Converts a photo to [sepia-tone][sepia], like old-timey photos are. To
do so, take any RGB pixel and covert it to a new RGB pixel using this
formula:

    new R = 0.393 * old R + 0.769 * old G + 0.189 * old B
    new G = 0.349 * old R + 0.686 * old G + 0.168 * old B
    new B = 0.272 * old R + 0.534 * old G + 0.131 * old B

Be careful because sometimes this formula produces values bigger
than 1. That is never legal in JPL and you must cap pixel values at 1.0

Your test program should sepia-tone `sample.png` and write the
sepia-toned image to `sample-sepia.png`.

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
to `sample-blurry.png`.

# Testing Your Code

Go to the "[Releases][releases]" associated with this repository, and
find the most recent release. You should find that it has attachments
called `jplc-linux`, `jplc-macos`, and `jplc-windows.exe`. These are
executable files; download the relevant one for your computer. (If
you're using some other operating system, please contact the
instructor.)

[releases]: https://github.com/utah-cs4470-sp23/class/releases

On macOS and Linux, you'll need to mark the downloaded file
executable. Do that with:

    chmod +x <jplc-file>

You should now be able to execute JPL code with:

    <jplc-file> --eval <jpl-file> <args ...>

**Make sure to pass the `--eval` flag**; if you don't pass it, you'll
get a crash with a strange error message (because we haven't updated
most of our compiler to match the 2023 version of JPL).

For example, on macOS you should be able to run the `gradient.jpl`
program like so:

    ~/Downloads $ chmod +x jplc-macos
    ~/Downloads $ ./jplc-macos --eval ~/jpl/examples/gradient.jpl
    [13.137360095977783s] let gradient_image = (array[i : H, j : W] gradient(i, j, W, H))
    Compilation succeeded: evaluation complete

Note that the `gradient` program took 13 seconds to run. That's
because `--eval` _interprets_ the resulting JPL file. In fact, it is a
very slow and naive AST interpreter.

At this point you should open `gradient.png` and make sure it contains
a color gradient.

This interpreter is not supposed to crash. However, this compiler is
very new and it is not particularly well tested. If you suspect that
you have run into a compiler bug, please bring this up on the Discord
and we'll try to get it fixed.

This interpeter also does not produce great error messages and we
apologize in advance for that. (If you hate the error messages that it
produces, then hopefully this will motivate you to do a better job in
your own compiler!)

You can find the correct output for every function [in the auto-grader
repository](https://github.com/utah-cs4470-sp23/grader/tree/main/hw1).
If you generate images that are *similar* to the expected output, but
not quite the same, you may be able to use the Imagemagick `compare`
tool. If it's installed on your system, you can run a command like
this:

    compare your-output.png correct-output.png diff.png
    
Then the `diff.png` image will highlight differing pixels in red. The
auto-grader is a bit more lenient than that and allows pixels to
differ a tiny amount. You can see what the auto-grader sees by passing
some extra flags to `compare`:

    compare -fuzz 1% -metric AE your-output.png correct-output.png diff.png

As before, differing pixels are red.

# Submission and grading

This assignment is due Friday Jan 13.

We are happy to discuss problems and solutions with you on Discord, in
office hours, or by appointment. Please do not post full solutions to
individual problems in the Discord.

Each of your programs should be named after the function it mainly
contains and include both the function and the corresponding test
code. These files should be located in the `examples/` of your
repository. So, for example, `examples/blur.jpl` should contain your
blur function and test code.

The rubrik is:

| Weight | Function   |
|--------|------------|
| 5%     | `subtract` |
| 10%    | `red`      |
| 15%    | `circle`   |
| 15%    | `invert`   |
| 25%    | `sepia`    |
| 30%    | `blur`     |

Your solutions will be auto-graded. The auto-grader will use Github
Actions and run on Ubuntu using the most recent release of the
interpreter described above. The output text or images will be
compared to gold-standard solutions using the Imagemagick `compare`
tool.
