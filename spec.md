JPL Specification
=================

JPL is a simple array-oriented language mainly meant for graphics
code. This specification describes the 2025 edition of the language.

Lexical Syntax
--------------

JPL contains 7 kinds of tokens: keywords, punctuation, variables,
integer literals, float literals, strings, and newlines. There can
also be whitespace between the tokens.

The *keywords* are: `array`, `assert`, `bool`, `else`, `false`, `float`,
`fn`, `if`, `image`, `int`, `let`, `print`, `read`, `return`, `show`,
`struct`, `sum`, `then`, `time`, `to`, `true`, `type`, `void`, `write`.

The *punctuation* characters are: `:`, `{`, `}`, `(`, `)`, `[`, `]`,
`,`, `=`, `+`, `-`, `*`, `/`, `%`, `<`, `>`, `&&`, `||`, `==`, `!=`,
`<=`, `>=`.

*Variables* are a letter (upper case A-Z or lower case a-z) followed
by any number of letters or digits, underscores, *except* when the
sequence of letters and digits is a keyword.

An *integer* literal is a sequence of one or more digits. An integer
literal that does not map to a 64-bit two's complement value
(e.g. 9999999999999999999999) is a compile-time error; in other words
the minimum integer value is `-2^63` and the maximum integer value is
`2^63 - 1`.

A *float* literal is a sequence of digits, a dot, and another sequence
of digits; one of the two sequences must be non-empty. The dot is
required. Scientific notation is not supported. Literals mapping to
infinity are not supported. Do not write your own code to convert
float syntax to float values! (It is much harder and subtler than you
probably think!) Use the C library function `strtod` or its binding in
your language of choice (ex. Python's `float`) to perform the
conversion. If this conversion is error-free, then the literal is
legal, otherwise the JPL compiler must signal a compile-time error.

*Strings* are a double quote, any sequence of legal characters except
double quote and newline, and then another double quote. Character
escapes like `\n` aren't supported (you're not going to need them).
Multi-line string literals are not supported.

*Whitespace* is allowed between any two tokens and consists of any
sequence of spaces, line comments, block comments, and newline
escapes. Line comments are a `//`, followed by any sequence of
non-newline characters. Block comments are a `/*`, followed by
any sequence of characters not including `*/`, followed by `*/`.
Newline escapes are a backslash followed immediately by a newline.

A *newline* is any sequence of newline characters (ASCII 10) and
whitespace containing at least one newline, except at the beginning of
the program. This means multiple consecutive newline tokens should
never occur (they should be squashed into one newline token). Note
that the newline at the end of a line comment still generates a
newline token, but newlines inside a block comment do not. However, if
a program starts with whitespace or newlines, no newline token should
be generated.

All other characters are illegal, and an appropriate lexer error
should be raised if any occur in a JPL program. That includes tabs and
carriage returns (part of a Windows newline). More generally, only
ASII character 10 and characters 32-127 are valid in a JPL program.


Syntax
------

There are five syntax classes: types, expressions, statements,
lvalues, and commands. A program is a sequence of commands terminated
by newlines. A valid program must end with a newline. In the grammar
below, semicolons represent newline tokens.

Ellipses represent repetition with a separator. For example, `( <expr>
, ... )`means any sequence of left parenthesis, expression, comma,
expression, comma, and so on until a final expression, and then a
right parenthesis. Likewise, `( <variable> : <expr> , ... )` repeats a
sequence of `<variable> : <expr>` constructions. Repetition never
allows zero repetitions. Each comma must be followed by a repetend: a
final trailing comma is not allowed.

### Primitive Values

The promitrive types are Booleans, 64-bit signed integers, and 64-bit
(double precision) floats:

```
type : int
     | bool
     | float
```

JPL does not have any implicit conversions between types. This means
only one of `x / 2` or `x / 2.` will typecheck, for any given `x`.

Values of these types can be written directly:

```
expr : <integer>
     | <float>
     | true
     | false
```

Mathematical operators expect both operands to have the same type
(either integer or float) and yield a result of the same type as the
input:

```
expr : <expr> + <expr>
     | <expr> - <expr>
     | <expr> * <expr>
     | <expr> / <expr>
     | <expr> % <expr>
```

Comparisons likewise expect both operands to have the same type
(integer, boolean, or float), and yield Booleans:

```
expr : <expr> < <expr>
     | <expr> > <expr>
     | <expr> == <expr>
     | <expr> != <expr>
     | <expr> <= <expr>
     | <expr> >= <expr>
```

Booleans are compared with `false` less than `true`.

Boolean operators, where `&&` and `||` are short-circuiting:

```
expr : <expr> && <expr>
     | <expr> || <expr>
```

Note that unary negation isn't included. While inconvenient for
programming, this makes the parser easier to write. Unary negation
`-x` can always be replaced with `0 - x` or `0. - x`, while unary
negation `!c` can be replaced with `c == false`.

Finally, there is a conditional operator, which only evaluates the
relevant branch. Both branches have to yield the same type.

```
expr : if <expr> then <expr> else <expr>
```

Precedence is necessary to disambiguate certain constructs. The
binding strength is:

- Postfix `[]` and `.` have the highest precedence
- Multiplicative binary operators `*`, `/`, and `%` have third highest
- Additive binary operators `+` and `-` are next
- Binary comparisons `<`, `>`, `<=`, `>=`, `==`, and `!=` are next
- Boolean binary operators `&&` and `||` are next
- Prefix `array`, `sum`, and `if` expressions have the lowest precedence

All operators associate to the left. Explicit parentheses can be used
to override precedence:

```
expr : ( <expr> )
```

> For example,
>
>    array[i : N] if ! y[i] then 0 else 1 + 2 * x[i]
>
> is equivalent to
>
>    (array[i : N] (if (! (y[i])) then (0) else (1 + (2 * > (x[i])))))

### Arrays

JPL supports multidimensional arrays:

```
type : <type> [ ]
     | <type> [ , ... ]
```

The array syntax allows any number of commas between the square
brackets; for example, `int[,,,]` means a four-dimensional array of
integers. The dimensionality of an array is called its "rank". Note
the distinction between `int[,]` (a two-dimensional or rank-2 array)
and `int[][]` (a one-dimensional or rank-1 array of one-dimensional or
rank-1 arrays). The difference is that the first is guaranteed to be
rectangular, while the second is not.

You can index into an array, as long as the number of indices matches
the array's rank:

```
expr : <expr> [ <expr> , ... ]
```

Array indices are zero-based, and empty arrays (with a dimension of
length zero) are not allowed.

One-dimensional arrays can be constructed directly:

```
expr : [ <expr> , ... ]
```

However, higher-dimensional arrays *can't* be constructed directly.
Instead, you need to use JPL's `array` and `sum` constructs:

```
expr : array [ <variable> : <expr> , ... ] <expr>
     | sum [ <variable> : <expr> , ... ] <expr>
```

Each expression in the list of bindings (between the square brackets)
must produce an integer, and in the body of the loop (after the square
brackets) those variables are bound to integers. `array` expressions
yield an array, whose rank is given by the number of bindings. `sum`
expressions yield an integer or a float, depending on the body
expression.

### Structures

JPL also has structure definitions:

```
cmd : struct <variable> { ;
          <variable> : <type> ;
          ... ;
      }
```

Once defined, the structure becomes a type:

```
type : void
     | <variable>
```

Here, `void` is a built-in zero-size structure, as if it were defined
like so:

    struct void {
    }

However, note that a real `struct` definition has to have at least one
field, so this definition isn't actually valid JPL. That's why `void`
is built-in.

To construct a structure, you need to give a value for each field:

```
expr : <variable> { <variable> : <expr> , ... }
```

The special `void` structure has just one value:

```
expr : void
```

You can then get a particular field's value with the dot operator:

```
expr : <expr> . <variable>
```

Naturally, when constructing or accessing a structure, all of the
field names have to be valid and be constructed with the right type.

### Input/Output

Commands are only available at the top level (not inside functions)
and are the only way side effects occur. Commands deal largely with
input and output.

PNG images are the main input/output format. PNG files read as
`rgba[H,W]`, where the `rgba` structure is defined like so:

    struct rgba {
        r : float
        g : float
        b : float
        a : float
    }

Color values should be between 0.0 and 1.0. Values below 0.0
are clipped to 0.0 and values above 1.0 are clipped to 1.0.
NaN and negative zero map to 0.0.

While text I/O is not JPL's main input/output facility, it is useful
for debugging and in a few other cases. You can print any JPL value
with `show`, or print a literal string with `print`:

```
cmd  : print <string>
     | show <expr>
```

Printing outputs the string followed by a newline. Showing outputs the
expression in a form similar to how it could be constructed in JPL.
However, multi-dimensional arrays are output using a format containing
semicolons to indicate the end of rows, which can't be parsed by JPL.

You can also time an expression with `time`:

```
expr : time <expr>
```

This evaluates the expression and then prints the word `[time]`
followed by the time (in milliseconds) and the expression to the
console. The format of the expression is not defined.

### Functions

Functions are defined like so:

```
cmd : fn <variable> ( <lvalue> : <type> , ... ) : <type> { ; 
          <stmt> ;
          ... ;
          return <expr> ;
      }
```

Note that each function has a single `return`, which must be
explicitly written.

They can then be called like so:

```
expr : <variable> ( <expr> , ... )
```

Zero-argument functions can't be defined or called. This makes parsing
a bit more convenient, and doesn't impact usability much.

Variables are defined with `let` commands/statements. (They are also
introduced by function arguments and `read` commands.)

```
stmt : let <lvalue> = <expr>
cmd : stmt
```

The LValue on the left hand side of the equal sign could bind just a
variable:

```
lvalue : <variable>
```

However, it can also bind an array variable and also integer variables
for the length of that array (in each dimension) at the same time:

```
lvalue : <variable> [ <variable> , ... ]
```

Once a variable is defined, it can be used:

```
expr : <variable>
```

Assertions evaluate the expression and abort the program (after
printing the user's error message) if it is false. The expression must
return a boolean:

```
stmt : assert <expr> , <string>
```

Semantics
---------

### Values

Integers behave like 64-bit two's-complement signed integers. Integer
overflows wrap around in two's complement fashion. There are no
unsigned types or operators.

Floats behave like by 64-bit IEEE-754 floating point values. Keep in
mind that a number of interesting floating point values exist, such as
-0, inf, and NaN. Operations on these values should follow standard
IEEE 754 semantics: `inf + 1.0 = inf`, and `0.0 / 0.0 = NaN`. Floating
point instructions should generally give you the desired behavior for
free, it is built into the FP hardware unit.

Integer division is defined to wrap to zero. Integer modulus is
defined so that `a` and `a % b` have the same sign. Division by or
modulo zero is an error. (This matches the x86\_64 `idiv` instruction.)

Don't implement your own version of the modulus operator on floats!
Use the C standard library's `fmod` operation, or your chosen
language's equivalent.[1]

[1]: Python's modulus operator is different: do not use it! Python's
    `math.fmod` is closer, but you must check for a zero right-hand
    side and return `NaN` instead of throwing an exception.

The compiler does not have to preserve the contents, count, or order
of `time` expressions. That said, times should be as precise as
possible---at least millisecond accuracy.

### Builtins

JPL must provide a global `args` variable of type `int[]` containing
integers provided in the command line program's command line, and a
variable `argnum` of type `int` containing the number of arguments.
The program name itself should not be part of that list or that count.
It is an error to invoke a JPL program with command-line arguments
that are not 64-bit signed integer values.

> Consider the following JPL program:
>
> ```
> show args
> ```
> 
> Call this program like so:
>
>     ./program 1 2 3 4
>
> It must print `args = [1, 2, 3, 4]`.

JPL compilers must provide builtin functions including the following
math functions:

+ Of one `float` argument, returning a `float`:
  `sqrt`, `exp`, `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, and `log`
+ Of two `float` arguments, returning a `float`:
  `pow` and `atan2`
+ The `to_float` function, which converts an `int` to a `float`
+ The `to_int` function, which converts a `float` to an `int`, with
  positive and negative infinity converting into the maximum and
  minimum integers, and NaN converting to 0.
JPL compilers must also provide the builtin `rgba` type, defined as
described above.

### Binding

Variable bindings are lexical, meaning that every time a function is
invoked it introduces a new variable scope. It is always a
compile-time error for a JPL program to refer to a name that has not
yet been bound. Function definitions are interpreted in file order,
and may not use the same name as either another function or a builtin.

Recursive calls are allowed. However, mutual recursion is not (because
one of the functions would have to refer to a function defined later
in that file). So, for example, while this program looks like it
should typecheck, it is not legal JPL because the body of `f()` refers
to function `g()` which has not yet been bound:

```
fn f(x : int) : int {
   return g(x)
}

let y = f(3)

fn g(x : int) : int {
   return y
}
```

Shadowing is always illegal in JPL: it is a compile time error to bind
a name that is already visible from the current scope, including a
type alias. Thus, no JPL program can contain two functions with the
same name, and it is always an error to introduce a function with the
same name as a built-in function. It is not even legal to have a
function-scoped variable with the same name as a global.

### Errors

A JPL program has a compilation phase and an execution phase. It is
possible that a JPL implementation will want to blur the distinction
between these phases (e.g. because it is an interpreter or a JIT
compiler), but conceptually they must exist.

At compile time, a JPL implementation must reject syntactically
malformed inputs (those that are not accepted by the JPL grammar) as
well as inputs that are accepted by the grammar, but that fail to type
check. For example, a program containing the expression `a < b` where
`a` and `b` have different types, must be rejected at compile time.
Note that array sizes are not part of the type system (though array
rank is). Compile-time error messages should mention the line number
where the problem was first detected and also a brief description of
the problem.

At run time, a JPL implementation must detect erroneous conditions. If
any such condition occurs, the JPL program must be cleanly terminated
(no segfaults or other OS-level traps!) and a brief, appropriate error
message must be displayed that begins with the text `[abort]`.
Run-time errors include:

- an integer division or modulus operation by zero[^1]

- out-of-bounds array access

- `sum` or `array` with non-positive bounds

- any failing assertion

[^1]: Note that floating-point divisions and modulus operations with
      zero right-hand arguments are not erroneous: they return NaN.

Or they may be *external* errors:

- attempting to read a file that does not exist

- attempting to write a file to a full disk

- attempting to write to a write-protected location

- any other I/O function failing

- out of memory

When an internal or external error occurs, the process running the
compiled JPL program should exit with non-zero status code.

JPL compilers must preserve internal errors: the compiler shouldn't
change a program with internal errors into one without, or vice versa.
JPL compilers must therefore emit code to check integer division
arguments, array bounds, and assertions. It is acceptable to not emit
that code when the JPL compiler can prove that the assertion cannot
fail. JPL compilers must also preserve termination and
non-termination.

JPL compilers need not strictly preserve external errors---that's
impossible without a strict contract from the operating system---but
should preserve the order and arguments of system calls, except for
the time information in `time` expressions. In practice, this is not
hard, because only the top-level commands have I/O effects.

JPL compilers also need not preserve the type of internal or external
error (for example, bounds checks could be implemented as assertions).

There are some rarer exceptional conditions, like stack overflow or
signal handling, where JPL programs are allowed to segfault or
otherwise terminate uncleanly, and need not be preserved. As long as
the compiler doesn't go out of its way to mess with this things should
be fine.

### Implementation Limits

A JPL compiler is not obligated to support a nesting depth (as
measured by the height of the program AST following the grammar in
this specification) larger than 64, nor is it required to support
arrays of rank larger than 64, structures wider than 64 elements, or
functions that take more than 64 arguments. Basically, almost any
occurrence of `...` in this specification only needs to be expanded 64
times by a JPL compiler.

However, the number of elements in an array constructed via an `array`
loop should be limited only by available memory.

Runtime Representation
----------------------

The special `void` structures has zero size.

Integers, floats, and booleans all take up 64 bits. For booleans, this
might seem wasteful, but it avoids having to deal with padding or
alignment.

Structures are laid out contiguously in memory with no padding.

Arrays are a list of 64-bit dimension sizes and a 64-bit data pointer.
The actual contents of the array are stored on the heap, in
row-contiguous order.

All values are always 64-bit aligned.

Everything is passed by value, by which we mean that the data pointer
inside an array is a reference but the rest of the array data (the
list of dimension sizes) is copied.

JPL Compiler Command Line Interface
-----------------------------------

Every execution of a JPL compiler should print either `Compilation
succeeded\n` or else `Compilation failed\n` to the standard output
stream (stdout). The contents of the standard error stream (stderr)
are unspecified---a compiler can use this for debug output, error
tracebacks, or any other information it wants.

The compilation should succeed if the input program is legal JPL, and
in this case the compiler should not print anything else to stdout.
The compilation should fail if the input program is not legal JPL, in
which case, in addition to the `Compilation failed` message, an error
message describing what is wrong with the input program should also be
printed to stdout. A JPL compiler should produce no other output,
except in cases described below.

A JPL compiler is required to support the following command line options,
which may occur in any order:

- Exactly one filespec, which specifies both a path and a filename. A
  filespec may be relative to the current working directory, or it may
  be absolute. The filespec describes the location of a file
  containing JPL code to be compiled.

- Zero or one flags indicating actions taken by the compiler:

  - `-l`: Perform lexical analysis only, printing the tokens to
    stdout. In this case, the compilation is considered to be
    successful if the input file contains only the lexemes described
    in this spec; otherwise, the compilation fails.

  - `-p`: Perform lexical analysis and parsing only, pretty-printing
    the parsed program back to ASCII text in a format based on
    s-expressions that is described in your assignments.  In this
    case, the compilation is considered to be successful if the input
    program corresponds to the grammar described in your current
    assignment; otherwise, the compilation fails.

  - `-t`: Perform lexical analysis, parsing, and type checking (but not
    code generation). In this case, the compilation is considered to be
    successful if the input program is fully legal JPL; otherwise
    the compilation fails.

  - `-s`: Perform lexical analysis, parsing, type checking,
    optimization (if any), and code generation. This must succeed for
    any legal JPL program and output NASM-formatted assembly code to
    the standard output.

  - `-O<n>`: Set the optimization level. The value `n` must be a
    number, and indicates the optimization level to perform. This flag
    only does anything when combined with `-s`.

If the command line options to the JPL compiler do not meet these
requirements, or if the specified file does not exist or cannot be
accessed, neither `Compilation successful` nor `Compilation failed`
should be printed, but rather a terse error message should be printed
before the compiler exits.

It is permissible for a JPL compiler to accept additional
single-letter command line flags. For example, the `-o <filename>`
flag might cause the compiler to output to a file instead of to the
standard output stream, or `-r` might ask the compiler to assemble,
link, and run a JPL program. When such a flag is specified, it is
understood that the JPL compiler is operating outside of this spec.
Thus, violating the "should produce no other output" clause above is
acceptable. However, these extra flags must be off by default.
