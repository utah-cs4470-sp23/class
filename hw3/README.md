Assignment 3: Starting your JPL Parser
======================================

For this assignment you will start working on your compiler's parser;
you'll continue working on the parser in Assignments 4 and 5. In this
assignment, the focus will be on two key steps:

 - Defining the AST classes
 - Parsing commands
 
## The JPL subset

Formally, for this assignment you'll build a parser for a subset of
JPL.


```
cmd  : read image <string> to <argument>
     | write image <expr> to <string>
     | type <variable> = <type>
     | let <lvalue> = <expr>
     | assert <expr> , <string>
     | print <string>
     | show <expr>

type : int
     | bool
     | float
     | <variable>

expr : <integer>
     | <float>
     | true
     | false
     | <variable>

argument : <variable>

lvalue : <argument>
```

Informally, this subset is basically just commands, not including
`time` and function definitions. It does not include statements, and
it includes only the most basic types, expressions, arguments, and
l-values. We've chosen this subset because it can be parsed without
recursion, but still includes some (simple) JPL expressions.

Since you're going to be working on the parser for the next three
weeks, we strongly recommend you build a good foundation for that in
this assignment---future assignments will be harder, because we'll
assume you're extending a reasonably-well-structured existing parser.

To demonstrate that your parser works, you must to implement the
parse-only mode of the [command line specification][jpl-p]. In this
mode, your compiler should parse the input file and produce an output
that looks like this:

[jpl-p]: https://github.com/utah-cs4470-sp23/class/blob/main/spec.md

```
(ReadCmd "photo.png" (VarArgument photo))
(AssertCmd (VarExpr a) "Photo must be 800 pixels wide")
(AssertCmd (VarExpr b) "Photo must be 600 pixels tall")
(LetCmd (ArgLValue (VarArgument middle)) (VarExpr photo))
(WriteCmd (VarExpr middle) "profile.png")
```

Your compiler must also print `Compilation failed` when a parser error
is encountered and `Compilation succeeded` when parsing works. We will
use this when testing your code. The output format is formally defined
below.

## Output format

Your parser should produce output in what's called an "S-expression"
format. This format can be generated directly from your AST nodes. We
recommend giving each AST node a `toString` method (or your language's
equivalent) that turns that AST node into the S-expression string.

While S-expressions look kind of confusing, they follow a very simple
rule: every AST node should turn into:

- An open parenthesis
- Followed by the name of the AST node
- Followed by each field of the AST node
  - each preceded by a space
  - in the same order as in the grammar
  - if it is an AST node field, print its S-expression
  - if it is a `<string>` field, print it with quotation marks
  - otherwise, just print it directly
- Followed by a close parenthesis

For example, the grammatical rule for `read` is:

    expr : read image <string> to <argument>

The corresponding AST node is called `ReadCmd` and has two fields, a
string and an argument. So its `toString` method would look like this:

```
public class ReadCmd extends Cmd {
    String filename;
    Argument arg;

    public String toString() {
        out = "(ReadCmd";
        out += " " + this.string_sexp(this.filename);
        out += this.arg.toString();
        out += ")";
        return out;
    }
}
```

Here the `string_sexp` method takes a `String` argument and returns
that string with double quotes around it:

```
public class ASTNode {

    public String string_sexp(String input) {
        return '"' + input + '"';
    }
}
```

Note that in this implementation, the `ReadCmd` calls `toString` on an
`Argument`. That would also implement a `toString` method, like this:

```
public class VarArgument extends Argument {
    String name;

    public String toString() {
        out = "(VarArgument";
        out += " " + this.name;
        out += ")";
        return out;
    }
}
```

The AST node names that you must use in your S-expression output are:

    ReadCmd WriteCmd TypeCmd LetCmd AssertCmd PrintCmd ShowCmd
    IntType FloatType BoolType VarType
    IntExpr FloatExpr VarExpr TrueExpr FalseExpr
    VarArgument
    ArgLValue

Printing floats is difficult, and differs across langauges, so please
cast any float arguments to 64-bit integers and print those. For
example, the JPL expression `3.14159` would print as `(FloatExpr 3)`.
In C++ you can do that by printing with `%ld`; in Python with `{:d}`;
in Java, cast to a `long` and print that.

The auto-grader will automatically indent your S-expressions and split
them across lines in a standard way, so we recommend not worrying
about that in your code.

## Defining AST classes

While internal implementation details of your compiler are in
principle up to you, we strongly recommend defining your AST classes
in a uniform way.

We recommend you define a top-level class called `ASTNode` or similar,
containing one field, the start position of that AST node in the
source file (as a byte position). You can set this field when you
create any AST node, based on the start position of the first token in
this AST node. This start position will be useful for producing good
error messages throughout the rest of this compiler. If your lexer
doesn't store byte positions, it's probably worth going back and doing
that.

Then, for each grammatical class---here, `cmd`, `expr`, `type`,
`argument`, and `lvalue`, but in later assignments also
`stmt`---define a superclass with no fields. Name them something
uniform like `Cmd`, `Expr`, and so on.

Finally, for each "production"---that is, every possible rule in the
grammar---define a class. Name it after both the grammatical class and
the production itself. So for example, you might have `WriteCmd` and
`IntExpr` classes. You don't, strictly speaking, have to use the names
we require in the S-expression, but why not do that?

For each production class, give it fields for all of its non-trivial
tokens. For example, the `WriteCmd` should have a `string` field and
an `Argument` field, while an `IntegerExpr` should have an `int`
field.

## Writing the parser

We recommend defining a function for each grammatical class and a
function for each production. So, for example, you'd implement a
`parse_expr` method as well as `parse_intexpr`, `parse_floatexpr`, and
so on. These can take an index into the token list as their input, and
return an AST node and a new index as their output.

We recommend _not_ doing any arithmetic on the index directly in these
methods. It is too easy to make a mistake---forget to increment the
index at some point, for example---that will be hard to debug.
Instead, we recommend writing three helper methods: `peek_token`,
which returns type of the next token, `start_token` returns the start
position for the current token, and `expect_token` with the following
type signature:

```
public class Parser {
    public String expect_token(int, TokenType)
        throws ParserError { ... }
}
```

The two arguments are an index into the token list and a token type to
expect that token to be. If the token at that position doesn't have
that type, `expect_token` raises a `ParserError` error. If it does
have that type, `expect_token` returns its contents, which will be the
variable name or the integer value or whatever.

You can then call `expect_token(i++, type)` in any parser function to
assert that the next token has a certain type and simultaneously to
increment `i`. (When you do this, put each `expect_token` on its own
line, so you don't get argument evaluation order issues.)

Each grammatical class function should call `peek_token` and then
dispatch to the appropriate production function (or raise an error).
Each production function should call `expect_token` and grammatical
class functions. We recommend only creating an AST node object at the
end of a production function, after you've successfully checked that
you've got all the right tokens.

**Use of a parser generator is prohibited.** In this class you are
required to write the parser by hand. This is more common than not in
complex production compilers (generally because parser generators
produce poor error messages) and also because we believe writing a
parser by hand is important to understanding parsing. The graders
enforce rules like this with spot checks, so if you do use a parser
generator we may discover it weeks from now and have to revise your
grade to a 0. Do not do it.

## Arguments and LValues

Even though `argument` and `lvalue` have only have one production each
in the subset of JPL that we are considering in this assignment, we
still recommend you define all of the associated AST node classes and
parsing functions. It'll seem annoying now, but will save you time in
later parsing assignments, which are generally harder.

Your output S-expression must contain `ArgLValue` and `VarArgument`
nodes.

## Integers and floats

When you parse an integer literal expression or a float literal
expression, you need to check JPL's [rules about numeric
constants][jpl-num]. Specifically, you will need to:

 - Make sure integer literals fit into 64-bit signed twos-complement
   integers
 - Make sure float literals fit into 64-bit double-precision IEEE-754
   floats without being infinite or `NaN`
 - Convert the string representing that integer or float into your
   language's 64-bit integer or float type.

*Use your language's built in integer and float parser for these
tasks.* Specifically, use:

 - `Long.parseLong` and `Double.parseDouble` in Java, catching
   `NumberFormatException`s to detect integer overflow and using
   `Double.isInfinite` and `Double.isNaN` to detect bad floating-point
   values.
 - `strtol` and `strtod` in C++, checking `errno` for `ERANGE` to
   detect overflow and using `isnan` in `math.h` to detect NaNs.
 - `int` and `float` in Python, catching exceptions and using
   `math.isnan` and `math.isinf` to detect bad floating-point values.
   Because integers in Python are arbitrary-size, to detect integer
   literals that are too big, you must manually compare them against
   `2 << 63 - 1` and `-2 << 63` to detect overflow.

We want to emphasize again that converting strings to numeric
values---especially converting strings to floating-point values---is
way harder than you think it is, and you should definitely not do this
on your own, because you are extremely likely to get it wrong!

# Testing your code

The JPL interpreter in the "[Releases][releases]" supports the `-p`
operation you are being asked to implement. You can run it on any test
file to see the correct parsing of that file:

    ~/Downloads $ ./jplc-macos -p ~/jpl/examples/cat.jpl
    (ReadCmd "input.png" (VarArgument img))
    (WriteCmd (VarExpr img) "output.png")
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
repository](https://github.com/utah-cs4470-sp23/grader/tree/main/hw3).
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

This assignment is due Friday Jan 27.

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
