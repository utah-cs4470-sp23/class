Assignment 6: Type-checking Expressions
=======================================

For this assignment you start on your compiler's type checker. The
type checker runs after the parser and traverses the AST returned by
the parser. For each expression in the program, the type checker
computes its type, and raises an error if the type is invalid.
 
## The expression subset

In this assignment, you will build a type checker for a subset of JPL.
This subset is basically "all expressions, except anything having to
do with variables". More formally, the grammar subset is:

```
cmd : show <expr>

expr : <integer>
     | <float>
     | <variable>
     | true
     | false
     | <expr> + <expr>
     | <expr> - <expr>
     | <expr> * <expr>
     | <expr> / <expr>
     | <expr> % <expr>
     | - <expr>
     | <expr> < <expr>
     | <expr> > <expr>
     | <expr> == <expr>
     | <expr> != <expr>
     | <expr> <= <expr>
     | <expr> >= <expr>
     | <expr> && <expr>
     | <expr> || <expr>
     | ! <expr>
     | if <expr> then <expr> else <expr>
     | { <expr> , ... }
     | [ <expr> , ... ]
     | ( <expr> )
     | <expr> { <integer> }
     | <expr> [ <expr> , ... ]
```

The only command of interest is the `show` command, because in this
assignment we want to focus on type checking expressions only. The
missing expressions (which you don't need to handle in this
assignment) are `VarExpr`, `CallExpr`, `ArrayLoopExpr`, and
`SumLoopExpr`.

Additionally, in this subset, there will only be one variable name
used, `pict`, which your type checker must assign the type
`{float,float,float,float}[,]`, the usual JPL type for images. We'll
make the handling of variables more complicated in the next
assignment, but for now, it keeps things simple.

Note that expressions in this subset include all of JPL's kinds of
types, like integers, floats, booleans, arrays of various ranks, and
tuples of various widths.

You *do not need to* modify your parser to restrict programs to this
subset. You should still run the normal parser; it's just that your
type checker is allowed to assume every program passed to it will only
use the AST nodes above.

For every expression in the subset above, you must compute a type
using JPL's [type checking rules](../spec.md#Expressions). The rules
are also formally given in the slides from Lecture 8, which you can
find on Canvas. Your parser must implement the `-t` and print
`Compilation failed` or `Compilation succeeded` when type checking. We
will use this when testing your compiler.

## Printing the output

Much like in the parser, your type checker must produce S-expression
parse trees when passed the `-t` and print `Compilation failed` or
`Compilation succeeded` when type checking. The only difference from
Homeworks 3–5 is that each expression AST node must print its type as
its first field. For example, the program:

    show -48.3 / 24.1

Must produce the output:

    (ShowCmd
     (BinopExpr
      (FloatType)
      (UnopExpr (FloatType) - (FloatExpr (FloatType) 48))
      /
      (FloatExpr (FloatType) 24)))

Note that the `BinopExpr`, `UnopExpr`, and `FloatExpr` nodes have the
type as the first argument---in this expression, all four nodes have
`(FloatType)`. Types are printed using the same S-expression format
that you've been using. Note also that the `ShowCmd` does not print a
type, because it is not an expression.

The goal of this output format is to allow you to reuse as much
S-expression output code as possible.

We recommend internally adding a `Type` field to the `Expr` superclass
of all expression AST nodes, whose value is initialized to `null` (or
your language's equivalent) and which is set by the type checker. Then
modify whatever method you use to produce S-expression to include that
field in the output if it is not `null`. You ought to be able to
support both the parser output and the type checker output without
much extra work. That said, it is ultimately up to you how your AST
classes are represented internally, as long as they print correctly.

## Computing types

As discussed in class, we recommend defining a new set of types for
type trees, separate from your types for type AST nodes. That means
defining a top-level type for type tree (traditionally, this is called
`Ty`) and subtypes for each kind of type (such as `IntTy`, `ArrayTy`,
and so on). This separation will be useful to ensure that you resolve
type definitions (the `type` command) in later assignments.

We additionally recommend defining a helper method to test if two
types are equal, perhaps by overriding the `==` method if you're in
C++ or Python. This equality method should be recursive in the case of
compound types like arrays and tuples. For example, to test whether a
tuple type is equal to another type, you'd test that the second type
is a tuple type, has the same number of parts, and whether each
corresponding part is equal.

Finally, we recommend defining a `type_of` method which takes an
expression AST node as an input and produces a type tree as output.
This method should:

- Recursively compute the type of each subexpression
- Apply the type rules to determine what the type of the output is
- Raise a type error if the type rules are violated
- Construct that output type and save it on the expression AST node
- Return the output type as well

Returning the output type is convenient for writing the type checker,
while storing the output type makes it convenient to produce
S-expression output.

Finally, define a top-level `typecheck` method, which iterates over
the list of `Cmd`s that make up the program you parsed. Each of them
will be `ShowCmd`s (due to the subset considered in this assignment);
check that and then call `type_of` on the `ShowCmd`'s subexpression.

In your compiler, call `typecheck` after parsing, which should store
the type of each expression. Then use your exising S-expression
printer to print the resulting expressions, which should print those
stored types.

## For C++ specifically

In C++, we recommend using `shared_ptr` in the type tree. This is
because it is convenient to store multiple pointers to the same part
of some type tree; for example, the type systems states than an
`ArrayIndexExpr` has the same type as the base expression's base type;
this involves having two pointers to the base type. Type trees should
never form cycles, so using `shared_ptr` in this context is safe. The
`shared_ptr` class will automatically handle de-allocation for you.

We recommend storing types on `Expr` nodes with a `type` field on
marked `mutable` (and declared as a `share_ptr<Ty>`). Marking the
field `mutable` ensures that it can be modified even through a `const`
pointer to the `Expr`, which is what we'll be doing in the `type_of`
method.

For traversing the AST, we recommend having the `type_of` method take
a standard pointer to a constant expression node, that is, a `const
Expr*`. While using a raw pointer is generally a bad idea, we should
neither be allocating, nor modifying, nor deallocating AST nodes in
the type checker. (Except to store types on the AST nodes, allowed by
marking that field `mutable`.) At the moment, there isn't a standard
idiom in C++ for "borrowed" ownership of the kind we need in our type
checker, so this is the best solution.

# Testing your code

Just like in the last homework, the JPL interpreter in the
"[Releases][releases]" supports the `-t` operation you are being asked
to implement. You can run it on any test file to see the correct
parsing of that file:

    ~/Downloads $ ./jplc-macos -p ~/jpl/examples/cat.jpl
    (ShowCmd (ArrayLoopExpr (ArrayType (IntType) 1)
               x (IntExpr (IntType) 1)
               (BinopExpr (IntType) (IntExpr (IntType) 1)
                          +
                          (VarExpr (IntType) x))))
    Compilation succeeded: parsing complete

Naturally, this JPL interpreter is a program and can have bugs. If you
think you've found one, contact the instructors on Discord.

[releases]: https://github.com/utah-cs4470-sp23/class/releases

Pretty-printing and comparing these S-expression outputs works as in
[prior assignments](../hw5/README.md).

You can find the tests and expected outputs [in the auto-grader
repository](https://github.com/utah-cs4470-sp23/grader/tree/main/hw6).
These tests come in five parts, corresponding to the five directories
of tests.

The directories `ok` (Part 1) and `ok-fuzzer` (Part 2) contain valid
JPL programs, which your parser must parse correctly.

The ones named `fail-fuzzer1` (Part 3), `fail-fuzzer` (Part 4), and
`fail-fuzzer3` (Part 5) contain invalid programs that your parser must
raise an error on.

You can run these tests on your computer by downloading the
auto-grader and running it like so:

    make -C <auto-grader directory> DIR=<compiler directory> PART=<part>
    
Generally speaking, Part 1 is somewhat easier than the other parts and
we recommend you start there. Typically, Parts 3, 4, and 5 are the
hardest, so we recommend making sure you pass all other parts first.

Depending on how exactly you write your parser, you might find that
you pass Parts 3, 4, and 5 very early. This usually happens because
you haven't actually implemented any of the JPL subset and therefore
reject all programs. That means you successfully reject invalid
programs, passing Parts 3, 4, and 5. However, don't get too excited:
you're rejecting these programs for the wrong reason, and will
probably stop rejecting some of them once you implement the full JPL
subset type checker.

# Submission and grading

This assignment is due Friday Feb 17.

We are happy to discuss problems and solutions with you on Discord, in
office hours, or by appointment.

Your compiler must be runnable as described in the [Testing your
code][Testing your code] section. If the auto-grader cannot run your
code, you will not receive credit. The auto-grader output is available
to you at any time, as many times as you want. Make use of it.

The rubrik is:

| Weight | Function |
|--------|----------|
| 45%    | Part 1   |
| 25%    | Part 2   |
| 10%    | Part 3   |
| 10%    | Part 4   |
| 10%    | Part 5   |

Your solutions will be auto-graded. The auto-grader will use Github
Actions and runs on Ubuntu using the tests described above.
