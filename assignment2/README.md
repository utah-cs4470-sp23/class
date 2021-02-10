# Assignment 2: Parsing Commands and Statements

Your second assignment is to build a parser for a subset of JPL on top
of the lexer you implemented for Assignment 1. This parser's job is to
turn an arbitrary sequence of tokens into either:

- an abstract syntax tree, or
- a parse error.

Specifically, you will be parsing the following grammar:

```
expr : <integer>
     | <float>
     | <variable>
     | <variable> ( <expr> , ... )
    
stmt : let <lvalue> = <expr>
     | assert <expr> , <string>
     | return <expr>

cmd  : read image <string> to <argument>
     | write image <expr> to <string>
     | print <string>
     | show <expr>
     | time <cmd>
     | <stmt>

lvalue : <argument>
argument : <variable>
```

This is a subset of the [full JPL grammar][full-grammar] in which you
can call functions, but you cannot define new functions.  Programs in
this subset can manipulate images using built-in filters. At the same
time, this subset avoids a lot of the trickier parts of JPL: complex
lvalues, function definitions, types, and precedence. We will deal with
these later.

[full-grammar]: https://github.com/utah-cs4470-sp21/jpl/blob/main/spec.md#syntax

You will need to define data types for your abstract syntax tree.
Specifically, you must define the node types `IntExpr`, `FloatExpr`,
`VarExpr`, and `CallExpr`; `LetStmt`, `AssertStmt`, and `ReturnStmt`;
`ReadImageCmd`, `WriteImageCmd`, `PrintCmd`, `ShowCmd`, `TimeCmd`, and
`StmtCmd`; `ArgLValue`; and `VarArgument`.

When parsing is successful, your parser should return a list of
commands. Use a standard type like an array, list, or vector for this.
Commands are separated by `NEWLINE` tokens, and the program itself is
terminated by an `END_OF_FILE` token. Neither of those tokens is
legal anywhere else in the program.

In C++, Java, and Python, you should use the object oriented
features of your compiler implementation language. For example, you
could define an `ASTNode` class, then define `Expr`, `Stmt`, `Cmd`,
`Argument`, and `LValue` classes that inherit from it, and then
classes for each possible node type inheriting from those. For
example, you'd have an `TimeCmd` inheriting from `Cmd`, like so:

``` {.java}
public class TimeCmd extends Cmd {
    public Cmd subcommand;
    
    public TimeCmd(Cmd scmd) {
        this.subcommand = scmd;
    }
}
```

We will talk about this more and look at example code in class.

While it is not required, we strongly recommend having a field on all
AST nodes containing that node's line number (usually the line number
that node started on). Remember that you will be reading a lot of your
own compiler's error messages!

Parser requirements:

- Integer and floating point literals must be checked for validity.
  For example, `let x = 99999999999999999999999999999999999999` cannot
  be compiled because that number does not fit into a 64-bit signed
  integer.

- The AST node for function calls must have two children: a string
  corresponding to the function name, and a list of expression
  objects: one for each argument.

- The AST node for `let` statements must have an lvalue object as a
  child, not the variable name directly. Likewise `read image`
  commands must have an argument object as a child. This is to make it
  easy to later add more types of lvalues and arguments.

- You must implement the `-p` flag from the [JPL command line
  interface][jpl-cmdline], and it must print (to STDOUT) `Compilation
  successful` when parsing is successful and `Compilation failed` when
  a parse error is encountered. We will use that output to test your code.

The "parse-only" mode that is triggered by the `-p` flag should dump
your program's AST, in a format like the one shown here. AST nodes are
printed using
[s-expressions](https://en.wikipedia.org/wiki/S-expression) such as
`(NodeName args ...)`. Print strings with double quotes, and print
integers and variable names (*inside* their respective AST nodes)
directly. Printing floats is difficult, and differs across langauges,
so please cast any float arguments to 64-bit integers and print those.
For example, the JPL expression `3.14159` would print as `(FloatExpr
3)`. In C++ you can do that by printing with `%ld`; in Python with
`{:d}`; in Java, cast to a `long` and print that. Arguments should be
printed in the same order as in the grammar. You can put any number of
spaces between the node name and the arguments (or between arguments);
indentation and line breaking, like below, is optional.

[jpl-cmdline]: https://github.com/utah-cs4470-sp21/jpl/blob/main/spec.md#jpl-compiler-command-line-interface

```
$ cat sepia.jpl
read image "photo.png" to photo
assert has_width(photo, 800), "Photo must be 800 pixels wide"
assert has_height(photo, 600), "Photo must be 600 pixels tall"
let middle = cut_center(photo)
write image sepia(middle) to "profile.png"

$ ./jplc -p sepia.jpl
(ReadImageCmd "photo.png" (VarArgument photo))
(StmtCmd (AssertStmt (CallExpr has_width (VarExpr photo) (IntExpr 800)) "Photo must be 800 pixels wide"))
(StmtCmd (AssertStmt (CallExpr has_height (VarExpr photo) (IntExpr 600)) "Photo must be 600 pixels tall"))
(StmtCmd (LetStmt (ArgLValue (VarArgument middle)) (CallExpr cut_center (VarExpr photo))))
(WriteImageCmd (CallExpr sepia (VarExpr middle)) "profile.png")
```

You should feel free to pretty-print your compiler's output using this
Racket program:

``` {.racket}
#lang racket
(for ([line (in-port read)] #:break (equal? line 'Compilation))
  (pretty-print line (current-output-port) 1))
```

You can install Racket on your own machine and also it is already
available on the CADE lab machines.

Your compiler, when running in parse-only mode, **must not** implement
checking that goes beyond matching the grammar. For example, you must
not cause compilation to fail if the program being compiled passes the
wrong number of arguments to a function.


## CHECKIN: Due Friday February 12

Write class definitions for all major types of expression nodes,
and any classes those definitions inherit from.

Implement a `Parser` class, with two member variables: a list of
tokens and an integer position into it.

Implement a `parse_expression` method on that class. It should take no
arguments and return either an AST node (on success) or some null
value like `nullptr`, `null`, or `None` on failure.

The `parse_expression` method should succeed when the tokens in the
token list, starting with the token pointed to by the positive
variable, form a valid expression, and fail otherwise. On success, the
position variable should be updated to point to the first token
_after_ the parsed expression. On failure, the position variable
should be unchanged.

There can be more than one way to parse an expression starting from a
given point; for example, in `f ( )` either `f` is a variable
reference or `f ( )` is a function call. Your `parse_expression`
function must prefer the longer parse.

Finally, implement `print` methods for each expression node. Each
`print` method should take no arguments and return a string. For
example, calling `parse_expression` on the tokens in `f ( )`, and then
calling `print` on the resulting AST node, should produce the string
`(CallExpr f)`.

Place all the class definitions, including the `parse_expression` and
`print` methods, in an `assignment2.txt` file in the root directory of
your repo. (We ask for the text file extension because we want to open
it easily, but please make it valid code in whatever language you are
using.)

## HANDIN: Due Friday February 19

Submit a parser for the subset of JPL defined in this assignment. The
code must be in your repo, and we must be able to run it on a CADE lab
Linux machine by going to the top-level directory of your repo and
typing this:

```
make run TEST=input.jpl
```

Here `input.jpl` is a file that we will supply. For this assignment,
your makefile should supply the `-p` flag itself. As before, please
test everything early so we can solve any problems before the
deadline.

We are providing a script, `test-parser`, to test your parser, and we
will use the same script to grade your parser. The script compares
your output against reference output, and complains if they do not
exactly match (except for whitespace). Run it like this, specifying
your compiler executable instead of `../pavpan/compiler.py`:

```
$ ./test-parser ../pavpan/compiler.py
```

As always, even if the tests pass on your computer, or some other
computer, it does not count unless those tests also pass on a CADE
Linux machine. Since this is a hard requirement, please test it out
well before the due date so you have time to resolve any problems that
may come up.
