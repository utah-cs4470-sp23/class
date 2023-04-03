Assignment 12: Peephole Optimization
====================================

For this assignment you will add optimizations to your compiler.
 
# What you turn in

This assignment is due Friday April 7.

Your compiler must implement the `-s` flag and the `-O` flag. Your
compiler will be called with both `-s` and `-s -O1`. When called with
just `-s`, it should generate the same assembly code expected for
Assignments 9-11. When called with `-s -O1`, it should generate
assembly code with the optimizations listed below applied. The
[provided compiler][releases] supports this flag, so you can use it
for testing.

[releases]: https://github.com/utah-cs4470-sp23/class/releases

As with Assignment 11, none of the test cases require support for
function definitions.

You will add the following optimizations to your compiler:

 - Short constants as immediates, tested in `ok1`
 - Casts from boolean to integer, tested in `ok2`
 - Faster index expressions, tested in `ok3`
 - Multiplications by powers of 2 as shifts, tested in `ok4`
 - Reducing array copies for indexing, tested in `ok5`

There is no fuzzer test. This means that, if you'd like, you're free
to implement additional peephole optimizations beyond these.

Like in the prior two assignments, you are tested for matching the
assembly produced by the [provided compiler][releases], though you
don't need to match comments, whitespace, or exactly how you do
address arithmetic. The grading rubrik is:

| Tests | `ok1` | `ok2` | `ok3` | `ok4` | `ok5` |
|-------|-------|-------|-------|-------|-------|
| Grade | 10%   | 15%   | 20%   | 25%   | 30%   |

We recommending completing each part in order---that is, finishing
`ok1` before you move on to `ok2`, and so on.

# Organizing your code

All of the parts of this assignment require you to modify the code
generation phase in your compiler. We recommend adding an
`optimization_level` field to the `Assembly`, set in the constructor
based on command-line arguments, and then having the various `cg_xxx`
function check that field to determine whether to enable these
optimizations.

Broadly, peephole optimizations will look like this:

    class Function:
        def cg_int_expr(expr : Expr) -> list[str]:
            if self.assembly.optimization_level >= 1:
                # generate optimized assembly
                return
            # generate unoptimized assembly
            
In the simpler peephole optimizations, the `if` statement at the top
is the only thing you are adding. In more complex ones, you may need
to have more complex logic---but whatever logic you add, you should
keep the un-optimized form of the code unchanged from what you have
now.

# The peephole optimizations

You must implement six peephole optimizations.

## Short constants as immediates

Without optimizations, a constant expression like `17` generates the
following assembly code:

    mov rax, [rel CONST]
    push rax

This is inefficient, because it involves a read from memory, and the
memory may not even be in cache. Instead, it is much more efficient to
generate this assembly:

    push qword 17

Here the `qword` annotation is mandatory, because the assembler needs
to know whether you intended to push a 64-bit, 32-bit, or 16-bit
value.

On x86\_64, the only supported immediate values 32-bit values. So, for
example, the following are legal in assembly:

    push qword 2147483647
    push qword -2147483648

These values are the largest and smallest signed 32-bit integers.

However, the following is invalid:

    push qword 2147483648

This is invalid because this number does not fit in 32 bits.

Modify your `cg_int_expr` and `cg_bool_expr` functions to use
immediates for constants that fit in 32 bits. If the constant does not
fit in 32 bits, continue to use the slower load-from-constant code. In
many languages, you can test if a value fits into 32 bits like this:

    x & ((1 << 31) - 1) == x
   
Be very careful to make sure this computation happens with 64-bit integers.

With optimizations on, the data portion of your assembly file should
not have any integer constants that fit into 32 bits.

## Shorter boolean casts

In JPL, booleans and integers are separate types; if you want to
convert a boolean into an integer, you might write the following code:

    if b then 1 else 0

Without optimizations, this results in the following assembly code:

    ; Assume b is on the stack
    pop rax
    cmp rax, 0
    je .ELSE
    mov rax, [rel CONST1]
    push rax
    jmp .END
    .ELSE:
    mov rax, [rel CONST0]
    push rax
    .END:

None of this code is necessary, because the representation of a
boolean is already a 64-bit integer containing either 1 (for true) or
0 (for false). Add code to `cg_if_expr` to recognize the specific
pattern above and replace it with just the computation of `b`. Not
only is this way less code, but we also don't need to read from the
data section or handle jumps, which avoids polluting the CPU's branch
prediction register.

## Faster index expressions

In array index and array loop expressions, we need to compute a
pointer to the array entry. For example, in this `array` loop:

    array[i : 1024, j : 512, k : 256] body
    
We need to compute a pointer into the array being constructed to store
the body into it. That assembly code looks like this:

    mov rax, 0
    imul rax, [rsp + OFFSET_1024]
    add rax, [rsp + OFFSET_i]
    imul rax, [rsp + OFFSET_512]
    add rax, [rsp + OFFSET_j]
    imul rax, [rsp + OFFSET_256]
    add rax, [rsp + OFFSET_k]
    imul rax, SIZE
    add rax, [rsp + OFFSET_ptr]

Some of this code is wasteful. First of all, the first three
instructions set `rax` to zero, then multiply it by something
(resulting in 0), and then add the value at `[rsp + OFFSET2]`.
Instead, we can simply load that value directly:

    mov rax, [rsp + OFFSET_i]
    imul rax, [rsp + OFFSET_512]
    add rax, [rsp + OFFSET_j]
    imul rax, [rsp + OFFSET_256]
    add rax, [rsp + OFFSET_k]
    imul rax, SIZE
    add rax, [rsp + OFFSET_ptr]
    
The value here is avoiding an `imul`, which can contend on the
multiplication port. Make this change to in both `cg_array_index_expr`
and `cg_array_loop_expr`. If you factored the array indexing logic
into a helper method, you may only need to change that one method.

Moreover, in `array` loop examples like above, the memory argument to
the `imul` expression is fixed---it's 1024, 512, and 256. We can use
that to simplify the code further:

    mov rax, [rsp + OFFSET_i]
    imul rax, 512
    add rax, [rsp + OFFSET_j]
    imul rax, 256
    add rax, [rsp + OFFSET_k]
    imul rax, SIZE
    add rax, [rsp + OFFSET_ptr]

This reduces the use of address arithmetic ports, which can allow
these instructions to execute with more parallelism. Make sure to only
apply this optimization when the bound fits in 32 bits.

Implement this optimization in `cg_array_loop_expr`. Only apply this
optimization if the loop bounds are integer constants.

## Multiplications by power of two

When you execute the JPL expression `x * 256`, this generates the
following assembly code:

    ; compute x
    mov rax, [rel CONST_256]
    push rax
    pop r10
    pop rax
    imul rax, r10
    push rax
    
But multiplications by powers of two can be represented with a shift:

    ; compute x
    pop rax
    shl rax, 8
    push rax
    
Note that `8` is the log-base-2 of 256. Make this optimization in
`cg_binop_expr` when the right-hand operand is an integer constant
that is also a power of two. In most languages you can test that an
integer `x` is a power of two with this code:

    x >= 0 && x & (x - 1) == 0
    
Note that this uses the bitwise AND operator, `&`. You'll need to
compute the log-base-2 of a power of two; the easiest way to do that
is probably this loop:

    int n;
    for (n = 0; (1 << n) < x; n++);

It's a good idea to put both the is-power-of-two and the log-base-2
code into helper methods.

Make sure you handle all multiplications; you can probably search your
`Function` class for `imul` instructions to find them all:

 - Handle multiplying ith a power of two on the left or right. That
   is, both `x * 256` and `256 * x` should be optimized.
   
 - If you see something like `256 * 256`, handle it like `256 * x`.
   (Of course, a real compiler would constant-fold this.)

 - Also optimize multiplications in the array indexing portion of an
   `array` loop, if the bounds of the array are integer constants that
   are powers of two. For example, if `array[i : 256, j : 256] body`,
   make sure the array indexing logic shifts by 8 instead of
   multiplying by 256.

 - However, **do not** optimize the multiplications when allocating
   the array in an `array` loop, because `shl` doesn't set the
   overflow flag in the expected way.

Probably the most important one of these is optimizing multiplications
in array indexing, because those happens inside loops.

## Reducing array copies

When you write an expression like `a[10, 12]`, which is an array index
into a variable, the generated assembly goes through these steps.

 - Copy the array `a` to the top of the stack
 - Evaluate the indices in reverse order
 - Check that each index is in bounds
 - Compute the array index
 - Drop everything from the stack
 - Copy the array index to the stack

If the array is already in a local variable, the first step is
wasteful, because the array is already on the stack---it just might
not be at the top of the stack.

In assembly terms, the normal assembly for indexing into `a[10, 12]`
looks like this:

    mov rax, 0
    imul rax, [rsp + 0 + 24]
    add rax, [rsp + 0]
    imul rax, [rsp + 8 + 24]
    add rax, [rsp + 8]
    imul rax, [rsp + 16 + 24]
    add rax, [rsp + 16]
    imul rax, SIZE
    add rax, [rsp + 24 + 24]

Here, there are two kinds of address: `[rsp + 8I]` indexes into
the indices, which are on top of the stack, while `[rsp + 8I + 24]`
indexes into the array, which is just below the indices.

Modify your array indexing code to allow the array to be elsewhere on
the stack. To do so, compute a `GAP` value, which without
optimizations is 8 times the rank of the array, and generate this
assembly code:

    mov rax, 0
    imul rax, [rsp + 0 + GAP]
    add rax, [rsp + 0]
    imul rax, [rsp + 8 + GAP]
    add rax, [rsp + 8]
    imul rax, [rsp + 16 + GAP]
    add rax, [rsp + 16]
    imul rax, SIZE
    add rax, [rsp + 24 + GAP]

When optimizations are enabled, *if the array is a local variable*, do
not copy it to the top of the stack. Instead, set `GAP` to be the 8
times the rank of the array *plus* the difference between the array's
offset from RBP and the stack size at the beginning of
`cg_array_index_expr`. For example, if the current stack size is 48
bytes, and the array is at `RBP + 16`, meaning an offset of -16, and
the array has size 24 bytes, then the `GAP` should be the array offset
should be 48 - (-16) + 24 = 88.

When this optimization is enabled, since you don't copy the array to
the top of the stack, make sure you also don't free it! Also make sure
this optimization works together with all earlier optimizations, such
as the better array indexing and the multiplication-to-shifts
optimization.

The upshot of this optimization is that we read the array bounds and
pointer out of whereever the array is located on the stack, even if
it's not at the top of the stack.

Let me give a bit more detail on where this `GAP` computation comes
from. Imagine an array of rank `R`. Without optimization, the array is
copied to the top of the stack, and then `R` indices are pushed on top
of it, meaning that the array is `[rsp + 8R]`. That's why the `GAP` is
`8*R` without optimizations.

However, suppose the array is at `[rbp - OFFSET]` instead. Well,
`RBP = RSP + stack_size`, so the the array is at:

    [rsp + (stack_size - OFFSET)]

Then `R` indices are still pushed on top, so ultimately you get `GAP =
stack_size - OFFSET + 8*R`.

The reason this optimization is important is that we expect a lot of
important code, like a matrix multiply, a neural network convolution,
or a graphics kernel, to index into arrays inside a tight loop.
Moreover, arrays are pretty big, so copying them needlessly is a
waste.

# Extra challenges

There's no extra credit on this assignment, but if you found it
interesting, here are some more fun optimizations we decided not to
assign.

It's not too hard to replace a sequence of RSP changes with a single
one. For example, you might fold this:

    add rsp, 8
    add rsp, 8
    add rsp, 24
    sub rsp, 24
    
into just this:

    add rsp, 16

This should lead to speedups of 5% on code that does a lot of array
indexing or function calls, and general speedups of about 1% on most
code.

You can also detect the pattern `x % 2 == 0` and optimize that
specifically into something like `! (x & 1)`. Real compilers have
hundreds of patterns like this that address specific common code
patterns.

A more complicated version of the above optimization is to replace
integer division and modulus by powers of two with shifts right and
bitwise ands. What's hard about this is that integer division rounds
*to zero* while shifts right rounds *down*. So for negative numbers,
they round in opposite directions. You can do some bit tricks to
correct for this, and it's totally worth it because divison and
modulus are very slow (20-30 cycles!). But if you try this, be very
careful to test negative numbers, powers of two, `INT_MIN` and `0`.

Finally, we could take the array indexing optimization much further,
extending it to opimize tuple indexing like `i{0}`, nested tuple
indexing like `i{0}{1}` or even tuple indexing into an array index
like `a[10, 12]{0}`. All of these operations just move it in and out
of containers, so in all these cases, instead of copying data to the
stop of the stack, we can just carefullly track where it actually is.

One place to start implementing this is modify each of your
`cg_xxx_expr` functions to return the amount of bytes allocated and
the offset from `rsp` where the result is located. To begin with, all
existing functions should return the size of the return type as the
number of bytes allocated and `0` as the offset from RSP. Then local
variable references can output no instructions and just return a new
offset from RSP, and tuple indexes can adjust the offset instead of
outputing instructions. In general, this optimization can be taken
very far; in LLVM, the SROA pass does something like this.
