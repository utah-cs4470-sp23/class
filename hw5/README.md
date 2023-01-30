Assignment 5: Parsing Expressions
=================================

For this assignment you will finish working on your compiler's
parser by extending it to handle JPL's full expression syntax,
including the correct handling of precedence.
 
## The JPL subset

Formally, for this assignment you'll extend your parser from [Homework
4](../hw4/README.md) to support the following new syntactic elements:


```
expr : <expr> + <expr>
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
     | array [ <variable> : <expr> , ... ] <expr>
     | sum [ <variable> : <expr> , ... ] <expr>
```

Importantly, this grammar is ambiguous as written, and must be
disambiguated using JPL's [precedence rules](../spec.md#Expressions),
which in short give the following precedence order: indexing (which
you implemented last time); unary prefix operators; multiplicative
operators; additive operators; ordered comparison; unordered
comparison; boolean binary operators; and finally the prefix operators
`if`, `array`, and `sum`. Additionally, the binary operators need to
be disambiguated with regards to associativity (always left).

Even if you think that both parse trees are equally good (like for
`1 + 2 + 3`), your parser *must* return the parse tree specified above
(that is, `(1 + 2) + 3`).

## Printing the output

As in Homework 4, your parser must produce S-expression parse trees
when passed the `-p` and print `Compilation failed` or `Compilation
succeeded` when parsing. We will use this when testing your
code. The new AST node names are:

    UnopExpr BinopExpr IfExpr ArrayLoopExpr SumLoopExpr
    
Note that `UnopExpr` covers two different operators, while `BinopExpr`
covers thirteen different operators. For these AST classes, the
S-expression syntax includes the operator, such as:

    (UnopExpr ! (BinopExpr (VarExpr a) < (VarExpr b)))

We recommend creating a `UnopExpr` and `BinopExpr` class internally to
represent these types of expressions, with the operator itself stored
as enumerated types `Binop` and `Unop`. This is because the handling
for these operators is very similar throughout the rest of the
compiler, so giving them the same AST nodes simplifies your
implementation of future assignments.

Additionally, in the `ArrayLoopExpr` and `SumLoopExpr` AST classes,
the S-expression output contains a sequence of stand-alone variable
names (representing the `<variable>` tokens in the sequence of loop
bounds) and expressions (representing the `<expr>` phrase in the
sequence of loop bounds), followed by one final expression for the
loop body. That is,

    sum[i : H, j : W] f(i, j)

has the following S-expression representation:

    (SumLoopExpr i (VarExpr H) j (VarExpr W)
     (CallExpr (VarExpr i) (VarExpr j)))

Note that in the `SumLoopExpr`, the `i` and `j` are `<variable>`s, so
they are just printed directly, but inside the loop body, the `i` and
`j` are `<expr>`s, so they become `(VarExpr i)` and `(VarExpr j)`.

We recommend internally representing the bounds in a `SumLoopExpr`s or
`ArrayLoopExpr`s as a vector of string/expression pairs. You might
make both of these classes a subclass of a `LoopExpr` superclass,
because you'll have somewhat similar logic for `array` and `sum`
loops.

That said, it is ultimately up to you how your AST classes are
represented internally, as long as they print correctly.

## Handling precedence

JPL has eight levels of precedence; until now, your implementation
only had one (for postfix indexing expressions) or perhaps two (as you
may have separated out literal expressions in your implementation).

To handle precedence, you'll need to split the grammar given above
into having multiple levels of expressions---eight or perhaps 9
depending on how you do it. We recommend giving them memorable names
like `expr_ordered`, `expr_additive`, `expr_unop`, and similar.
Otherwise you will frequently get confused.

Writing a disambiguated grammar is tricky, and you may not get it
right on the first try. We recommend you write out the disambiguated
grammar before you start implementing anything, and test it on various
tricky expressions. For example, consider expressions like:

    1 + 2 + 3
    1 + 2 * 3
    array[] x + 1

and try to check if your grammar can accept the "wrong" parse. You do
this by writing out the "wrong" parse tree and checking if each phrase
matches a rule from your grammar. For example, this "wrong" parse:

    (array[] x) + 1
    
does match the grammar given at the top of this assignment because:

    x is an <expr> via "expr : <variable>"
    (array[] x) is an <expr> via "expr : array [ ... ] <expr>"
    (array[] x) + 1 is an <expr> via "expr : <expr> + <expr>"

This tells you that the grammar at the top of this assignment is
incorrect and needs further disambiguation. Make sure to test the
"right" parse trees too, because it is easy to accidentally write a
grammar that rejects too much.

You are done disambiguating when your grammar rejects all the "wrong"
parse trees but still accepts the "right" parse trees. If you'd like,
you can reach out to your instructors on Discord to have them check
over your grammar before you start implementing. (Be mindful of
deadlines and normal working hours!)

# Testing your code

Just like in the last homework, the JPL interpreter in the
"[Releases][releases]" supports the `-p` operation you are being asked
to implement. You can run it on any test file to see the correct
parsing of that file:

    ~/Downloads $ ./jplc-macos -p ~/jpl/examples/cat.jpl
    (ShowCmd (ArrayLoopExpr x (IntExpr 1)
               (BinopExpr (IntExpr 1) + (VarExpr x))))
    Compilation succeeded: parsing complete

Naturally, this JPL interpreter is a program and can have bugs. If you
think you've found one, contact the instructors on Discord.

[releases]: https://github.com/utah-cs4470-sp23/class/releases

For larger programs, it can be tedious to compare the S-expressions by
hand. Instead, save each output to a file and use `diff` to compare:

    diff wrong-output.txt right-output.txt
    
Moreover, for complex S-expressions it can still be hard to see the
difference when a whole command is all on one line. The JPL compiler
supports a special `--pp-sexp` command which pretty-prints
S-expressions. For example, if you run the parser on some long and
complex file:

    ~/Downloads $ ./jplc-macos -p ~/jpl/examples/nn/nn.jpl > out.sexp

You can then convert the output, `out.sexp`, to a pretty-printed
`out.pp` like this:

    ~/Downloads $ ./jplc-macos --pp-sexp out.sexp > out.pp

If you pretty-print both files before calling `diff` on them, it can
be easier to find the difference.

You can find the tests and expected outputs [in the auto-grader
repository](https://github.com/utah-cs4470-sp23/grader/tree/main/hw5).
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
subset parser.

# Submission and grading

This assignment is due Friday Feb 10.

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
