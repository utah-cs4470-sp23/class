JohnPavelLang Specification
======================

Lexical Syntax
--------------

Every byte of a valid JPL program has integer value 10 or 32-126
inclusive. Note that this means that space (32) and newline (10) are
the only valid whitespace characters (tabs are illegal).

Integer literals are an optional sign (plus or minus) and a non-empty
sequence of digits. An integer literal that does not map to a 64-bit
two's complement value (e.g. 9999999999999999999999) is a compile-time
error; in other words the minimum integer value is `-2^63` and the
maximum integer value is `2^63 - 1`.

Float literals are an optional sign (plus or minus), a sequence of
digits, a dot, and another sequence of digits; one of the two
sequences must be non-empty. Scientific notation is not supported.
Literals mapping to infinity are not supported. Negative zero is. Do
not write your own code to convert float syntax to float values. It is
much harder and subtler than you think! Use the C library function
`strtof` or its binding in your language of choice (ex. Python's
`float`) to perform the conversion. If this conversion is error-free,
then the literal is legal, otherwise the JPL compiler must signal a
compile-time error.

Strings are a double quote, any sequence of legal characters except
double quote and newline, and then another double quote. Character
escapes like `\n` aren't supported (you're not going to need them).

Variables are a letter (upper case A-Z or lower case a-z) followed by
any number of letters or digits, underscores, or dots, *except* when
the sequence of letters and digits is a keyword. By convention,
variables that contain dots are reserved for compiler intermediates
and should not be written in source code.

The keywords are: `array`, `assert`, `bool`, `else`, `false`,
`float3`, `float4`, `float`, `fn`, `if`, `int`, `let`, `print`,
`read`, `return`, `show`, `sum`, `then`, `time`, `to`, `true`, `write`.

Whitespace is allowed between any two tokens and consists of any
sequence of spaces, line comments, block comments, and newline
escapes. Line comments are a `//`, followed by any sequence of
non-newline characters, followed by but not including a newline or end
of file. Block comments are a `/*`, followed by any sequence of
characters not including `*/`, followed by `*/`). Newline escapes are
a backslash followed by a newline.

Syntax
------

There are four syntax classes: types, expressions, statements, and
commands. A program is a newline-separated sequence of commands.

There are also auxiliary syntax classes for lvalues, arguments, and
bindings.

In the grammar below, semicolons represent newline characters and
ellipses represent repetition with a separator. For example, `( <expr>
, ... )`means any sequence of left parenthesis, expression, comma,
expression, comma, and so on until a final expression, and then a
right parenthesis. Repetition always allows zero repetitions. Each
comma must be followed by a repetend: a final trailing comma is not
allowed.

# Type Syntax

The base types are Booleans, 64-bit integers, and 32-bit floats, of
which you can form arrays and tuples:

```
type : int
     | bool
     | float
     | float3
     | float4
     | <type> [ , ... ]
     | { <type> , ... }
```

The aliases `float3` and `float4` correspond to `{float,float,float}`
and `{float,float,float,float}`.

The array syntax allows any number of commas between the square
brackets; for example, `int[,,,]` means a four-dimensional array of
integers. The dimensionality of an array is called its "rank". Note
the distinction between `int[,]` (a two-dimensional or rank-2 array)
and `int[][]` (a one-dimensional or rank-1 array of one-dimensional or
rank-1 arrays). The difference is that the first is guaranteed to be
rectangular, while the second is not.

JPL does not have any implicit conversions between types.

# Expressions

The constructors for each basic type, where `true` and `false` are the
two Boolean values:

```
expr : <integer>
     | <float>
     | true
     | false
```

Variables, which always have a static type from the environment.

```
expr : <variable>
```

Tuple and array constructors:

```
expr : { <expr> , ... }
     | [ <expr> , ... ]
```

For tuples, each expression can have its own type, but for array
constructors, each expression must have the same type. Array
constructors always produce rank-1 arrays, but of course they may be
nested to produce arrays of arrays.

Note that both empty arrays and empty tuples are valid. An empty array
constructor is treated as creating an array of ints. So, for example,
`let x = []` creates a rank-1 array of integers that contains zero
elements.

Parentheses can be used to override precedence:

```
expr : ( <expr> )
```

Mathematical operators, which apply to integers and floats only:

```
expr : <expr> + <expr>
     | <expr> - <expr>
     | <expr> * <expr>
     | <expr> / <expr>
     | <expr> % <expr>
```

The multiplicative operators have higher precedence than the additive
ones. Within a precedence class, evaluation is left to right. Integer
overflows wrap around in two's complement fashion.

Keep in mind that a number of interesting floating point values exist,
such as -0, inf, and NaN. Operations on these values should follow
standard IEEE 754 semantics. For example, `inf + 1 = inf`, and `x / 0
= NaN`. Floating point instructions should generally give you the
desired behavior for free, it is built into the FP hardware unit.
Don't implement your own version of the modulus operator on floats!
Use the C standard library's `fmodf` operation, or your chosen
language's equivalent.[1]

[1]: Python's modulus operator is different: do not use it! Python's
    `math.fmod` is closer, but you must check for a zero right-hand
    side and return `NaN` instead of throwing an exception.


Comparisons, which yield Booleans:

```
expr : <expr> < <expr>
     | <expr> > <expr>
     | <expr> == <expr>
     | <expr> != <expr>
     | <expr> <= <expr>
     | <expr> >= <expr>
```

Boolean operators, where `&&` and `||` are short-circuiting:

```
expr : <expr> && <expr>
     | <expr> || <expr>
     | ! <expr>
```

Array and tuple operations. Both arrays and tuples are indexed by
integers and are zero-based. Tuple indices must be integer literals,
to support static typing. For arrays, the number of indexing
expressions must equal the array's rank.

```
expr : <expr> { <integer> }
     | <expr> [ <expr> , ... ]
```

A conditional operator, which only evaluates the relevant branch.

```
expr : if <expr> then <expr> else <expr>
```

Implicit loops. `sum` operates on integers and floats.

```
expr : array [ <variable> : <expr> , ... ] <expr>
     | sum [ <variable> : <expr> , ... ] <expr>
```

Each expression in the list of bindings (between the square brackets)
must produce an integer, and in the body of the loop (after the square
brackets) those variables are bound to integers. `array` expressions
yield an array, whose rank is given by the number of bindings. `sum`
expressions yield an integer or a float, depending on the sum of the
body expression. If the list of bindings is empty for either `array`
or `sum`, the body expression is evaluated and returned.

Function calls:

```
expr : <variable> ( <expr> , ... )
```

The type of a function call expression is the return type of the
function. Function calls can refer to either other functions defined
in the same file, or to builtin functions.

Precedence is necessary to disambiguate certain constructs. The
binding strength is:

- Postfix `[]` and `{}` have the highest precedence
- Prefix `!` has the next-highest precedence
- Multiplicative operators `*`, `/`, and `%` have second highest
- Additive operators `+` and `-` are next
- Comparisons `<`, `>`, `<=`, `>=`, `==`, and `!=` are next
- Boolean operators `&&` and `||` are next
- Prefix `array`, `sum`, and `if` expressions have the lowest
  precedence

> For example,
>
>    array[i : N] if ! y[i] then 0 else 1 + 2 * x[i]
>
> is equivalent to
>
>    (array[i : N] (if (! (y[i])) then (0) else (1 + (2 * > (x[i])))))

# Statements

Statements begin with keywords so they cannot be confused with
expressions. Statements are pure but not total.

Empty statements do nothing at all:

```
stmt : 
```

Let statements bind new variable names.

```
stmt : let <lvalue> = <expr>
```

A `let` statement's lvalue ("left value") is so called because it is
the left-hand argument to an assignment operator. These have multiple
formats, described below; the format of the lvalue must match the type
of the expression. Note that while this code is correctly typed:

```
let { { x, y }, { z, w } } = { { 32, 48 }, { 1, 2 } }
```

this code is not, and must be rejected by a JPL compiler:

```
let { { x, y }, { z, w } } = { { 32, 48, 1 }, { 2 } }
```

In other words, it is not only the contents of tuples that are
typechecked, but also the tuple structure.

Assertions evaluate the expression and abort the program (after
printing the user's error message) if it is false. The expression must
return a Boolean:

```
stmt : assert <expr> , <string>
```

A return statement inside a function ends execution of that function;
in this case the type of the returned expression must match the
function's return type. A return statement at the top level terminates
execution of the JPL program. In this case, the returned value must be
an integer, and it is used as the exit code for the process running
the JPL program. In the absence of an implicit return statement,
functions return `{}` (the empty tuple, of type `{}`) and the
top-level program returns `0`.

```
stmt : return <expr>
```

Finally, attribute statements can do anything at all, and should not
be written in source code. Instead, they can be used by the compiler
to record any information it wants during compilation.

```
stmt : attribute <any-non-nl-tokens>
```

The attribute statement is followed by any sequence of non-newline
tokens, followed by but not including, a newline. An attribute has no
semantics at the language level, and attributes should not appear in
source code. Attributes are used by individual compiler
implementations to communicate information between compiler passes.
All tokens between the attribute keyword and the end of the line are
considered to be part of the attribute statement.

# Commands

Commands are only available at the top level (not inside functions)
and are the only way side effects occur. Commands deal largely with
input and output.

PNG images and MP4 videos are the main input/output format. PNG files
read as `float4[W,H]` (in the RGBA color space) and MP4 as
`float3[W,H][T]` (in the RGB color space). Color values should be
between 0.0 and 1.0. Values below 0.0 are clipped to 0.0 and values
above 1.0 are clipped to 1.0. Infinities, NaN, and negative zero map
to 0.0.

Sound is not supported (though it would be cool!).

```
cmd  : read image <string> to <argument>
     | read video <string> to <argument>
     | write image <expr> to <string>
     | write video <expr> to <string>
```

Statements are also commands.

```
cmd  : <stmt>
```

At the top level, let statements can be used to define global
variables. Top-level return statements terminate the program.
Top-level attribute statements can be used to record the compilation
stages already completed or turn various error checks on and off.

Printing and timing statements are available for debugging purposes.

```
cmd  : print <string>
     | show <expr>
     | time <cmd>
```

Printing outputs the string followed by a newline. Showing outputs the
expression, a space, an equal sign, another space, and then the
expression's value. When outputting the expression, `show` need not
preserve parentheses or whitespace, as long as the output expression
parses to the same parse tree as the expression in the source code.
Times should be as precise as possible (at least millisecond
accuracy).

Functions are pretty standard:

```
cmd  : fn <variable> ( <binding> , ... ) : <type> { ;
           <stmt> ; ... ;
       }
```

Function definitions are interpreted in file order, and may not use
the same name as either another function or a builtin. Recursive calls
are allowed.

# Arguments, Lvalues, and Bindings

Binding forms in JPL allow binding a single value, or simultaneously
binding an array and its dimensions, or simultaneously binding
elements of a tuple. Lvalues are used in `let` statements while
bindings are used in argument definitions and include types. Both
share the "argument" syntax for binding variables and arrays,

Arguments can be raw variable bindings:

```
argument : <variable>
```

Or arguments can bind an array and its dimensions:

```
argument : <variable> [ <variable> , ... ]
```

It is a compile-time error if the number of dimension variables does
not equal the rank of the array. Also, only the outermost of a nested
array can have its dimensions bound in this fashion (since nested
arrays are not guaranteed to be rectangular).

Lvalues can bind the parts of a tuple:

```
lvalue : <argument>
       | { <lvalue> , ... }
```

Bindings are the same as lvalues but also include types:

```
binding : <argument> : <type>
        | { <binding> , ... }
```

> Here are some example arguments, and then the bindings they introduce:
> 
> `x : int` takes an `int` argument
> and binds `x : int`.
> 
> `x : int[]` takes an `int[]` argument
> and binds `x : int[]`.
> 
> `x[W] : int[]` takes an `int[]` argument
> and binds `x : int[]` and `W : int`.
> 
> `x[W, H] : int[,]` takes an `int[,]` argument
> and binds `x : int[,]`, `W : int`, `H : int`.
> 
> `x[W, H] : {int, float}[][,]` takes an `{int, float}[][,]` argument
> and binds `x : {int, float}[][,]`, `W : int`, `H : int`.
> 
> `{ x[W, H] : int[,], {y : int, z[T] : float} }`
> takes an `{int[,], {int, float[]}}`
> and binds `x : int[,]`, `W : int`, `H : int`,
> `y : int`, `z : float[]`, `T : int`.

Semantics
---------

A JPL program has a compilation phase and an execution phase. It is
possible that a JPL implementation will want to blur the distinction
between these phases (e.g. because it is an interpreter or a JIT
compiler), but conceptually they must exist.

At compile time, a JPL implementation must reject syntactically
malformed inputs (those that are not accepted by the JPL grammar) as
well as inputs that are accepted by the grammar, but that fail to type
check. For example, a program containing the expression `a < b` where
`a` has Boolean type, must be rejected at compile time. Note that
array sizes are not part of the type system. Compile-time error
messages should mention the line number where the problem was first
detected and also a brief description of the problem.

# Values

Integers are represented by 64-bit signed integers.

Floats are represented by 32-bit IEEE-754 floating point values.

Tuples are laid out contiguously in memory, with all values 32-bit
aligned.

Arrays are a list of 64-bit dimension sizes and a 64-bit data pointer.

Everything is passed by value, by which we mean that the data pointer
inside an array is a reference but the rest of the array data (the
list of dimension sizes) is copied.

By splitting array sizes from their data, it makes it easy to
rematerialize that info.

# Binding

Variable bindings are lexical, meaning that every time a function is
invoked it introduces a new variable scope.

It is always a compile-time error for a JPL program to refer to a name
that has not yet been bound. So, for example, while this program looks
like it should typecheck, it is not legal JPL because the body of f()
refers to function g() which has not yet been bound:

```
fn f(x : int) {
   return g(x)
}

let y = f(3)

fn g(x : int) {
   return y
}
```

Shadowing is always illegal in JPL: it is a compile time error to bind
a name that is already visible from the current scope. Thus, no JPL
program can contain two functions with the same name, and it is always
an error to introduce a function with the same name as a built-in
function. It is not even legal to have a function-scoped variable with
the same name as a global.

JPL compilers must provide builtin functions including the following
math functions:

+ Of one `float` argument, returning a `float`:
  `sqrt`, `exp`, `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, and `log`
+ Of two `float` arguments, returning a `float`:
  `pow` and `atan2`
+ The `float` function, which converts an `int` to a `float`
+ The `int` function, which converts a `float` to an `int`

They can also provide builtin functions whose name contains a dot,
which the compiler can use during compilation.

JPL must provide a global `args` variable of type `int[]` containing
integers provided in the command line program's command line, and a
variable `argnum` of type `int` containing the number of arguments.
The program name itself should not be part of that list or that count.

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

# Errors

At run time, a JPL implementation must detect erroneous conditions. If
any such condition occurs, the JPL program must be cleanly terminated
(no segfaults or other OS-level traps!) and a brief, appropriate error
message must be displayed. Run time errors can be *internal* errors,
namely:

- an integer division or modulus operation whose right-hand argument
  is zero[^1]

- out-of-bounds array access

- any failing assertion

[^1]: Note that floating-point divisions and modulus operations with
      zero right-hand arguments are not erroneous: they return NaN.

Or they may be *external* errors:

- failure to allocate memory

- failure of any I/O function (e.g. attempting to read a file that
  does not exist or attempting to write a file to a full disk or a
  write-protected location)

JPL compilers must preserve internal errors: the compiler shouldn't
change a program with internal errors into one without, or vice versa.
JPL compilers must therefore emit code to check integer division
arguments, array bounds, and assertions. It is acceptable to not emit
that code when the JPL compiler can prove that the assertion cannot
fail.

JPL compilers need not preserve external errors. Almost any change to
a program can cause a memory allocation to change from failing to not
failing in some obscure situations. JPL compilers also need not
preserve the type of internal or external error (for example, bounds
checks could be implemented as assertions).

There are some rarer exceptional conditions, like stack overflow,
where JPL programs are allowed to segfault or otherwise terminate
uncleanly, and need not be preserved. As long as the compiler doesn't
go out of its way to mess with this things should be fine.

JPL compilers must preserve termination and non-termination. They must
also preserve the order and contents of I/O effects and internal
errors, other than time information in `time` commands. In practice
this is not hard because only the top-level commands have I/O effects.

Elaboration
-----------

# Short-circuiting

It is convenient to elaborate short-circuting `&&` and `||` via `if`
statements:

    A && B -> if A then B else false
    A || B -> if A then true else B

# Errors

A JPL implementation could implement error checks by inserting
assertions into the program as it is being compiled. For example, a
function like this:

    fn example(i : int, j : int) {
      return i / j
    }

can be transformed into:

    fn example(i : int, j : int) {
        assert j != 0, "Error (example.jpl:2): Division by zero"
        return i / j
    }

# Arrays

It's helpful to introduce a type, `data`, for a pointer to data.
Then an array like `int[,]` can be represented in memory by the tuple
`{int, int, data}`, where the first two integers are the dimension.
Since arrays are immutable, it doesn't matter whether the tuple is
passed by reference or by value (though `data` should always be passed
by reference!) and in many cases it won't need to be, since the array
size going to be computable from other sources.

# Commands

It is convenient to convert commands into calls to builtin functions.
For example, a JPL could convert the command

```
read image "test.png" to a
```

into the statements

```
let { filename_length, filename_data } = \
  [ 116, 101, 115, 116, 46, 112, 110, 103, 0 ]
let a = read.image(filename_data)
```

Here the array of integers is the string `"test.png"` and the function
`read.image` (which contains a dot, so is as a compiler internal) has
type `(data) -> float4[,]`. Note the use of the `data` type described
above when discussing arrays.

Once all commands have been converted to builtin functions, the top
level contains only statements and can be converted to a function.

Implementation Limits
---------------------

A JPL compiler is not obligated to support a nesting depth (as
measured by the height of the program AST following the grammar in
this specification) larger than 64, nor is it required to support
arrays of rank larger than 64, tuples wider than 64 elements, or
functions that take more than 64 arguments.  Basically, almost any
occurrence of `...` in this specification only needs to be expanded 64
times by a JPL compiler. An exception is the `...` indicating the
repetition of statements in a function body: this should be limited
only by the amount of memory on the machine running the JPL compiler.
Similarly, the number of elements in an array should be limited only
by memory size.


Compilation
-----------

Loop fusion with this language leverages the rewrite

    (array[i, ...] expr0(i, ...) )[expr1, ...]
    ->
    expr0(expr1, ...)

This constructor / destructor pair eliminates the intermediate array,
Note that this is the same rewrites as inlining functions.

JPL Compiler Command Line Interface
-----------------------------------

Every execution of a JPL compiler should print either `Compilation
succeeded\n` or else `Compilation failed\n` to the standard output
stream (stdout). Nothing should be printed to the standard error
stream (stderr).

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
    the parsed program back to ASCII text. In this case, the
    compilation is considered to be successful if the input program
    corresponds to the grammar described in this spec; otherwise, the
    compilation fails. The pretty-printed program is not required to
    be syntactically identical to the original input program.
    However, it must be semantically identical. Furthermore, if the
    pretty-printed program is parsed and pretty-printed a second time,
    the pretty-printed output must be identical to the input.

  - `-t`: Perform lexical analysis, parsing, and type checking (but not
    code generation). In this case, the compilation is considered to be
    successful if the input program is fully legal JPL; otherwise
    the compilation fails.

If the command line options to the JPL compiler do not meet these
requirements, or if the specified file does not exist or cannot be
accessed, neither `Compilation successful` nor `Compilation failed`
should be printed, but rather a terse error message should be printed
before the compiler exits.

It is permissible for a JPL compiler to accept additional
single-letter command line flags. For example, `-d` might be used to
ask the JPL compiler to produce debugging output. When such a flag is
specified, it is understood that the JPL compiler is operating outside
of this spec. Thus, violating the "should produce no other output"
clause above is acceptable. However, these extra flags must be off by
default.
