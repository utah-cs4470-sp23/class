Assignment 13: Constant Propagation
===================================

For this assignment you will add a constant propagation pass to your
compiler.
 
# What you turn in

This assignment is due Friday April 14.

Your compiler must implement the `-s` flag and the `-O` flag. Your
compiler will be called with both `-s` and `-s -O2`. When called with
`-s`, it should generate the same assembly code expected for
Assignment 11. When called with `-s -O2`, it should generate assembly
code with constant propagation, explained below. The [provided
compiler][releases] supports this flag, so you can use it for testing.

[releases]: https://github.com/utah-cs4470-sp23/class/releases

As with Assignment 11 and 12, none of the test cases require support
for function definitions.

You will add the following optimizations to your compiler:

 - Propagate integer constants, tested in `ok1`
 - Propagate array sizes, tested in `ok2`

There are also fuzzer tests, in `ok-fuzzer`.

Like in the prior two assignments, you are tested for matching the
assembly produced by the [provided compiler][releases], though you
don't need to match comments, whitespace, or exactly how you do
address arithmetic. The grading rubrik is:

| Tests | `ok1` | `ok2` | `ok-fuzzer` |
|-------|-------|-------|-------------|
| Grade | 30%   | 50%   | 20%         |

We recommending completing each part in order---that is, finishing
`ok1` before you move on to `ok2`, and so on.

# AST Visitors

Constant propagation is a new phase of your compiler. It runs after
type checking and before code generation, but only if the optimization
level is at least 2.

We will use a "visitor pattern" to implement optimization passes.
Define a class (perhaps call it `ASTVisitor`) with methods like
`visit_int_expr`, `visit_let_cmd`, and so on. Each of these methods
should take as input an AST node and output either a null value or an
AST node. (You can represent the null value however you'd like, either
with a built-in singleton like `null` or an explicit wrapper like
`std::option`.)

Each `visit` method should look like this:

```
class ASTVisitor:
    def visit_array_index_expr(e : ArrayIndexExpr) -> Optional[Expr]:
        base2 = self.visit_expr(e.base)
        if base2: e.base = base2

        for i in range(len(e.indices)):
            index2 = self.visit_expr(e.indices[i])
            if index2: e.indices[i] = index2
        
        return None
```

In other words, every `visit` method should call a `visit` method on
each child AST node; and if that method returns a new AST node,
replace the old one with it.

We'll use this visitor class in both this assignment and the next one.

# Integer propagation

Define a `ConstantPropagation` class as a subclass of `ASTVisitor`. It
should have one field---a `context` that maps from variable names to
`CPValue`s. To start we'll need two kinds of `CPValue`s: `null`,
meaning an unknown integer value (perhaps the expression is not a
constant), and `IntValue`, which stores an integer. Depending on the
language you're using, you may need to create a singleton value to
represent the `null` case.

Add a `cp` field to your `Expr` class of type `CPValue` and
initialized to `null`. The goal of the `ConstantPropagation` pass is
to fill out these fields on as many `Expr`s as possible.

We'll need to define four methods of the visitor.

First, define `visit_int_expr`. These expressions are integer
constants, so their `cp` field needs to be set to an `IntValue`
containing the constant value.

Second, define `visit_let_cmd` and `visit_let_stmt`. This command /
statement should visit the right hand side and then check if the right
hand side has a non-null `CPValue`. If it does, extract the variable
name from the `let` and update the `context` to map that variable name
to that `CPValue`.

Finally, define `visit_var_expr`. This command shold look up the
variable name in the `context` and update the `VarExpr`'s `CPValue` if
it finds something in the `context`.

All of the `visit` methods should output `null`; the constant
propagation algorithm doesn't change the AST.

The upshot of these three steps is that if your compiler sees code
like this:

    let N = 32
    show array[i : N] i

Then it will first determine that the `IntExpr(32)` has an
`IntValue(12)`; then, save that `IntValue` in the `context` for the
variable `N`; and finally, save the same `IntValue` on the
`VarExpr(N)` where the variable is used in the second line.

# Using constants

Now that some of the expressions in your AST have `cp` fields with
`IntValue`s, go back into your code generator and use them. In
Assignment 12, you added several peephole optimizations that work when
something is an integer literal---short immediates, better array
indexing, and multiplications by powers of two. Until now, all of
those optimizations depend on an AST node being an `IntegerConstant`;
update them to instead depend on the AST node having an `IntValue`.

Specifically, the following optimizations are tested:

- Short immediates for small-enough integer constants
- Casts from boolean to integer
- Faster index expressions in `array` loops
- Multiplication by powers of two

Each of these optimizations should now apply to all expressions with
appropriate `IntValue`, even if those expressions are variable
references, not literal integers.

With this change, you should see the peephole optimizations apply in
more cases; for example, in this example:

    let N = 32
    show array[i : N] i

You should now be able to optimize the array indexing logic inside the
`array` loop to use explicit shifts, because even though the loop
bound is a variable (not an integer), that variable's value is known
to be an integer constant.

# Array length propagation

The peephole optimization for array indexing is actually quite
important for getting good performance. However, right now it only
applies to the implicit array index inside `array` loops; it doesn't
apply to explicit array indexing like `a[i, j]`. In order for it to
apply, we'd need to know the size of `a` in each dimension. Let's
extend constant propagation to do so.

First, define a new kind of `CPValue`, called `ArrayValue`; this
represents an array with known constant sizes. It's possible to have
an array that is a known constant length in one dimension and an
unknown length in another dimension, like this:

    let a = array[i : 16, j : args] i + j

Make sure this is representable by making an `ArrayValue` contain a
list of `CPValue`s.

Arrays are constructed in three ways: by array literals, by `array`
loops, and by `read` commands. Array literals always have a known,
constant length, while `array` loops have a known, constant length if
the loop bounds are known integer constants. Make sure your create
`ArrayValue`s in both cases. The `read` command reads a file on disk,
so the arrays it produces don't have known sizes.

Also make sure that an `ArrayArgument` binding like this also updates
the context with `IntValue`s for `H` and `W`:

    let a[H, W] = array[i : 16, j : 32] i + j

Binding an array with known sizes in this way should produce known
integers.

Finally, update the code generation for array indexing to use the
shorter, faster peephole optimization from Part 5 of Assignment 12, if
the array that it's indexing into has known, constant size. For
example, consider this code:

    let N = 2048
    let m1 = array[i : N, j : N] to_float(i+j)
    let m2 = array[i : N, j : N] to_float(i-j)
    time let res = array[i : N, j : N] sum[k : N] m1[i, k] * m2[k, j]

The variable `N` holds a known constant integer value, so the arrays
`m1` and `m2` have known, constant sizes. This means the array
indexing operations in `m1[i, k]` and `m2[k, j]` should use the
shorter form with immediate constants.

# Extra challenges

There's no extra credit on this assignment, but if you found it
interesting, here are some more fun optimizations we decided not to
assign.

You can extend the constant propagator to do some constant folding.
For example, if you add two known constants, you can do that addition
in your compiler. If you implement this, be especially careful with
how JPL treats integer division and modulus operations.

You can also compile out some of JPL's checks when all of the inputs
are known constants. For example, if you are indexing into an array
with known size, and the indices are also known, you should be able to
skip all of the bounds checks. Similarly, you could remove the
division by zero check.

All of this would be even more powerful if you added a range analysis.
In particular, JPL loop indices have a known range if the loop bound
is fixed. The range analysis would let you eliminate a lot of bounds
checks, leading to a substantial speedup.

In another direction, it's not too hard to extend the known integer
value tracking to handle more data structures, like tuples. This is
helpful in JPL, because it's convenient to define constants like this:

    let {H, W, N} = {800, 600, 12}

One interesting thing you can do is use `assert`s in a flow-sensitive
way to improve constant propagation. For example, a common JPL idiom
might be something like this:

    read image "a.png" to a[H, W]
    assert H == 600, "Wrong image"
    assert W == 800, "Wrong image"

Naturally, we can't know anything about the dimensions of an array
created by `read image` (since the file on disk might change between
the compile step and the run step). However, the `assert` statements
on the next line guarantee that any _later_ uses of `H` and `W` are
guaranteed to see the values 600 and 800. However, make sure not to
update _these_ uses of `H` and `W`, lest you compile them into the
constants `600` and `800` and the `assert` stops doing its job.

You can implement this by special-casing the pattern:

    assert <variable> == <integer>, <string>

This works and is pretty easy to implement in `visit_assert_cmd`. But
you can also write a recursive `must_be_true` method that takes in an
expression and updates the context based on the knowledge that the
expression must be true. Then your compiler could handle things like:

    assert H == 600 && W == 800, "Wrong image"

You can even store additional information in the `context` so that,
when you update the known values of `H` and `W`, you also update the
known lengths of `a`. If you do this, you should also store
information to track copies, like this:

    let a[y] = array[i : ...] i
    let x = y
    assert x == 800, "Meh"

Here, the `assert` should inform your compiler than `x` is 800, but
that in turn should inform your compiler that `y` is 800, which itself
should inform your compiler that the array `a` is 800 elements long.
Doing this kind of thing efficiently can be a big challenge, but could
bring big benefits in array processing code, where there are often
constaints that two arrays have the same size.
