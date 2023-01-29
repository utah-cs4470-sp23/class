Assignment 4: Parsing Recursing Syntax
======================================

For this assignment you will continue working on your compiler's
parser; modifying it to parse most of JPL syntax, especially the
recursive parts of the syntax.
 
## The JPL subset

Formally, for this assignment you'll extend your parser from [Homework
3](../hw3/README.md) to support the following new syntactic elements:


```
type : <type> [ , ... ]
     | { <type> , ... }

expr : { <expr> , ... }
     | [ <expr> , ... ]
     | ( <expr> )
     | <expr> { <integer> }
     | <expr> [ <expr> , ... ]
     | <variable> ( <expr> , ... )

cmd  : time <cmd>
     | fn <variable> ( <binding> , ... ) : <type> { ;
           <stmt> ; ... ;
       }

stmt : let <lvalue> = <expr>
     | assert <expr> , <string>
     | return <expr>

argument : <variable> [ <variable> , ... ]

lvalue : { <lvalue> , ... }

binding : { <binding> , ... }
        | <argument> : <type>
```

Note that in this grammar the semicolon `;` represents a `NEWLINE`
token. Informally, this subset is all of JPL except the arithmetic
operators.

As in Homework 3, your parser must produce S-expression parse trees
when passed the `-p` and print `Compilation failed` or `Compilation
succeeded` when parsing. We will use this when testing your
code. The new AST node names are:

    ArrayType TupleType
    TupleLiteralExpr ArrayLiteralExpr TupleIndexExpr ArrayIndexExpr
    IfExpr ArrayLoopExpr SumLoopExpr CallExpr
    TimeCmd FnCmd
    LetStmt AssertStmt ReturnStmt
    ArrayArgument TupleLValue TupleBinding VarBinding
    
Parenthesized expressions, as in the grammar rule `expr : ( <expr> )`,
do not produce AST nodes.

## Handling sequences

Many rules in this assignment's grammar rely on sequences. Keep in
mind the following rules for sequences in JPL:

- Every place in the grammar with a sequence allows for an empty
  sequence. Make sure you handle cases like empty array literals `[]`,
  empty indexing expressions `a[]`, and empty array loops `array[] e`.
- JPL does not allow terminal commas, so for example `[1, ]` is not a
  valid array literal.
- In JPL the delimiters are always paired, so for example `[1, 2}` is
  not a valid array or tuple literal.

You will probably find it helpful to write helper functions for parts
of the grammar that repeat in several places. For example, you may
want a helper function for sequences of expressions (shared between
calls, array indexing, and tuple and array literals) and for sequences
of `<variable> : <expr>` (shared between array and sum loops). We've
written JPL in a way that factoring out some common grammatical
features shouldn't be too hard.

It is, however, typically better to limit how many of these helper
methods you will have. This will ensure that your parser looks more
similar to the grammar, which will make it easier to debug. Also, some
of the helper you want to add will be able to match zero tokens---for
example, if you add a helper for sequences of expressions, that might
match zero tokens (in case of an empty sequence). Helper functions
that might match zero tokens make it harder to avoid infinite loops.

In your S-expression output, sequences typically just mean an AST node
has a varying number of children. For example, the type `{int, int}`
should have the following S-expression representation:

    (TupleType (IntType) (IntType))
    
whereas the type `{float, float, float, float}` has the following
S-expression representation:

    (TupleType (FloatType) (FloatType) (FloatType) (FloatType))

There are two exceptions to this rule. First of all, in function
definitions (`fn` commands) the function arguments are enclosed in an
additional set of parentheses. For example, this function:

    fn f(i : int, j : int) : int {
        return [i, j] 
    }

has the following S-expression representation:

    (FnCmd
     f
     ((VarBinding (VarArgument i) (IntType))
      (VarBinding (VarArgument j) (IntType)))
     (IntType)
     (ReturnStmt (ArrayLiteralExpr (VarExpr i) (VarExpr j))))

This is necessary for the S-expression representation to be
unambiguous.

Be careful when parsing `array` and `sum` loops. The loop

    sum[i : H, j : W] f(i, j)

has the following S-expression representation:

    (SumLoopExpr i (VarExpr H) j (VarExpr W)
     (CallExpr (VarExpr i) (VarExpr j)))
    
Note that in the `SumLoopExpr`, the `i` and `j` are `<variable>`s,
stored as a string on the `SumLoopExpr` AST node, so they are just
printed directly, but inside the loop body, the `i` and `j` are
`<expr>`s, stored inside the `CallExpr` as `VarExpr` AST nodes, so
they are printed as `(VarExpr i)` and `(VarExpr j)`.

## Avoiding infinite loops

The grammar given above contains "left recursion"; that is, in a rule
like `expr : <expr> { <integer> }`, the first step to matching an
expression seems to be recursively matching an expression, which would
lead to an infinite loop.

Naturally, your parser must not enter infinite loops; it must
terminate on all inputs. To handle cases like these, you will need to
_first_ parse an expression without tuple indices, and _then_ check if
the next token is a curly brace (and similarly for other forms of
indexing).

Make sure expressions such as `a{0}{0}` parse---this expression refers
to a tuple `a` whose `0`-th element is itself a tuple whose `0`-th
element is then retrieves. Similarly make sure mixed postfix operators
like `a(0)[0]{0}` work---this expression refers to a function `a`
which is called with an argument `0` and returns an array whose `0`-th
element is a tuple, whose `0`-th element is then retrieved.

The only way to avoid infinite loops is to draw out a call graph for
all of the methods in your code and, for each call from function `f`
to function `g`, determine whether it's possible that the index is the
same. Edges in the call graph where the index can be the same are bad.

- To parse array literals, `parse_arrayliteralexpr` will first expect
  an `LSQUARE` token and then call `parse_expr` to parse an expression.
  In this case, since `parse_arrayliteralexpr` incremented the index to
  advance through the `LSQURE` token, the `parse_arrayliteralexpr` to
  `parse_expr` call can't use the same index, so this edge isn't bad.
- To parse literals, `parse_expr` will first call `parse_literalexpr`.
  The edge from `parse_expr` to `parse_literalexpr` does not increment
  the index, so this edge is bad.

If the bad edges form a loop, then it's possible for your code to go
in an infinite loop. If the bad edges do _not_ form a loop, than every
"infinite" loop will eventually increment the index to the end of the
list of tokens and stop.

## Handling precedence

The grammar given above is ambiguous; for example, the expression
`array[x : 1] y[0]` could be parsed as either `array[x : 1] (y[0])` or
as `(array[x : 1] y)[0]`. You must parse these expressions according
to the [JPL specification](../spec.md); in this example, the first
parse is correct.

We recommend you split the `expr` grammatical class internally into
three classes: literal expressions (including the existing float /
integer / boolean literals, variable names, and the new array and
tuple literals), suffix expressions (for array and tuple indexing, and
calls), and prefix expressions (for `if`, `array`, and `sum`). Make
sure that these call each other in the right order and in the right
places. Make sure that tricky cases work, like

    if a then b else if c then d else e

You will likely find it helpful to write out a grammar with explicit
literal, prefix, and suffix expression classes, and then think
carefully which of these each instance of `<expr>` in the JPL grammar
refers to.

Ultimately, while there are precedence challenges to this assignment,
they should be minor. Homework 5 focuses primarily on operator
precedence.

# Testing your code

Just like in the last homework, the JPL interpreter in the
"[Releases][releases]" supports the `-p` operation you are being asked
to implement. You can run it on any test file to see the correct
parsing of that file:

    ~/Downloads $ ./jplc-macos -p ~/jpl/examples/cat.jpl
    (ShowCmd (ArrayLoopExpr ((x 1)) (ArrayIndexExpr y 0)))
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
repository](https://github.com/utah-cs4470-sp23/grader/tree/main/hw4).
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

This assignment is due Friday Feb 3.

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
