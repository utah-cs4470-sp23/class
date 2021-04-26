# Assignment 6: Optimizing JPL

Your sixth assignment is to add program optimization to JPL. In
particular, you will be adding four of the following optimizations
(you can choose which one you don't implement, except you must
implement constant folding):

- Constant folding for the basic math operations
- Constant propagation for integers, floats, and Booleans
- Dead code elimination for unused variables and dead branches
- Loop fusion for `array` expressions
- Peephole optimization for constant integer `sum` expressions

These optimizations will make certain code patterns much faster---in
fact, for certain (very specific) programs your optimized code will be
asymptotically faster than the original.

Your optimizations are strictly required to be *correct*: for
absolutely any valid JPL program, the unoptimized and optimized
programs must have the same behavior, as laid out in the [JPL
Specification](../spec.md). Pay particular attention to the "Errors"
subsection of the "Semantics" section.

## Structuring the Optimizer

Each optimization should be structured as a separate pass: a function
that takes as input a program and outputs a new program. Each
optimization should be correct on its own; that is, the optimization
should work on any valid JPL program and return an equivalent program.

The full JPL optimizer will then run a sequence of passes. It is good
debugging technique to re-type-check the program after each individual
pass runs. This will catch many bugs. It is also good debugging
technique to make it possible to output JPL source code for the
optimized program; this allows you to run both programs in the
instructors' compiler and compare behavior. (This can be done by
recursively converting the AST to a string in much the same way that
you currently turn an AST into s-expressions.)

When optimizing, pay particular attention to the edge cases of the
specification:

- Signed 64-bit integer overflow
- Division by zero (fatal for integers, valid for floats)
- Order of operations for floating-point arithmetic
- The semantics of floating-point and integer modulus
- Empty `array` and `sum` expressions

Also keep in mind that function calls may contain `assert`s that must
be preserved.

## The optimizations

**Constant Folding:** your optimizer must fold arithmetic operations
(`+`, `-`, `*`, `/`, and `%`) and comparisons (`<`, `>`, `>=`, `<=`,
`==`, and `!=`) on integers and floats when both arguments are
constants.

Be careful, because these operations have different behaviors for
integers and floats. If the program divides by integer zero, this is a
fatal error, so replace the entire expression evaluating the division:

    let x = 1 / 0
    ->
    assert false, "Division by zero error"

On the other hand, floating-point division by zero merely returns an
infinite (positive or negative) or not-a-number value. These values
have no direct representation in JPL, so in these cases you should not
fold the constants.

Also be careful to do signed 64-bit integer overflow for arithmetic
operations. Python integers are arbitrary-size, so in Python you will
have to handle overflow manually. Meanwhile, in C++, signed integer
overflow is undefined, so you will want to cast to unsigned integers
and then use a conditional to cast back. (In Java you should be fine,
though.)

Also be careful when implementing integer modulus, especially for
negative arguments.

Finally, make sure to use the correct types for constants.

**Constant Propagation:** your optimizer must propagate constant
integer, float, and bool arguments from definition to use. For
example, after the statement `let x = 3` all uses of `x` must be
replaced by the constant `3`.

**Dead Code Elimination:** your optimizer must remove definitions of
variables that are never used. When doing so, make sure not to remove
calls to functions, since those can have side effects. For example, if
`let x = f()` and `x` is unused, it is not valid to remove the
definition of `x`. It is, however, valid to remove a definition like
`let x = 3` or `let x = array[i : N] i`, if the defined variable is
never used.

Your optimizer must also replace `if` statements with a constant
condition with the appropriate branch of the `if` statement. For
example, it must replace `if true then f() else g()` with just `f()`.

Finally, your optimizer must remove `assert` statements with constant
true conditions. However, it must leave `assert` statements with
constant `false` conditions alone!

**Loop fusion:** your optimizer must replace accesses to
computed arrays with a direct computation of the value. That
description is pretty confusing, so consider instead this example:

    let x = array[i : 10] i * i
    let y = x[7]

In the array access `x[7]`, the accessed array `x` is computed via an
`array` expression. That means each index `i` of the array is computed
via `i * i`. So the access `x[7]` can be replaced with `7 * 7`.

This optimization is not valid if the array access is out of bounds.
Replacing `x[17]` with `17 * 17`, for example, is invalid because the
original program would error while the new program returns a value.

**Peephole optimization**: your optimizer must implement one peephole
optimization: turning a `sum` expression with a constant body into a
multiplication. For example, `sum[i : H, j : W] 7` should be replaced
with `H * W * 7`. This optimization should be executed for loops with
an integer body. Do not perform this optimization for summation loops
that have a float-typed expression, this would not be valid due to
rounding error.

## CHECKIN Due April 16

Implement constant folding in your compiler. Write four JPL programs
that stress-test different aspects of constant folding, and make sure
that they are compiled correctly. Call them `test-cf-[0-3].jpl`.

For each of the other three optimziations that you plan to implement,
write four JPL programs that stress-test different aspects of the
transformation. Call them `test-xx-[0-3].jpl` but change `xx` to be
the name or abbreviation of the optimization being tested. Since you
haven't yet written these optimizations, you must also write the
optimized versions of these programs, call these
`test-xx-[0-3]-output.jpl`. (If you did happen to write the
optimizations before the checkin due date, of course feel free to
create these files automatically using your compiler.)

You must write all 16 tests on your own, but once you have done so, it
is fine to trade test cases with other students who have also already
written their own. Put them all into a directory called `a6-tests`
that is a subdirectory of the root of your repository.

As always, make sure to push your changes to Github in the main branch
of your repository before the checkin due date.

## HANDIN Due April 28

Implement the three additional optimizations as described above.

Each of your optimiziations should be controlled by a command line flag
that can be provided zero or more times on the command line. These
are
- `-cf` for constant folding
- `-cp` for constant propagation
- `-dce` for dead code elimination
- `-lf` for loop fusion
- `-peep` for peepholes

These optimizations must be executed in the specified order. So, for
example, `jplc -cf -dce -cp -cf` would run constant folding, dead code
elimination, constant propagation, and then constant folding, in that
order.

You need to implement all five flags, even though you will implement
only 4 of the optimizatians. So one of your flags just won't do
anything.

Modify your makefile in such a way that it contains the following targets:
- `make a6-cf` runs constant folding and prints s-expression output
- `make a6-cp` runs constant propagation and prints s-expression output
- `make a6-dce` runs dead code eliminatiojn and prints s-expression output
- `make a6-lf` runs loop fusion and prints s-expression output
- `make a6-peep` runs peephole optimizations and prints s-expression output

Use these makefile targets to run your compiler on the provided test cases
in this directory. We'll do the same.

As always, make sure to push your changes to Github in the main branch
of your repository before the handin due date, and ensure that
everything works on CADE lab Linux machines.

