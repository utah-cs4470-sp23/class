# DO NOT READ. Assignment is unfinished and also extremely scary.

# Assignment 3: Typechecking and Code Generation for the JPL Subset

Your third assignment is to build a compiler for the subset of JPL
that you implemented a parser for in Assignment 2. This compiler's job
is to turn an AST into:

- an assembly function, or
- a naming or type error.

You will be implementing this compiler in three steps:

- Name resolution and type checking
- Flattening
- Code generation

Recall that the subset of JPL that we are working with contains values
of just four types: `bool`, `int`, `float`, and `int[,]`. In this
assignment we will refer to the last of these as `pict`. These
correspond to the following C types (you'll need `<stdint.h>`):

- `bool` corresponds to `int32_t` and takes up 4 bytes
- `int` corresponds to `int64_t` and takes up 8 bytes
- `float` corresponds to `double` and takes up 8 bytes
- `pict` corresponds to `struct { int64_t; int64_t; double *; }`
  and takes up 24 bytes (since all three components of the struct
  have 8-byte alignment, there is no padding)

Expressions in this subset are either constants, or they are a call to
one of the following functions:

- `sub_ints(int, int) : int`
- `sub_floats(float, float) : float`
- `has_size(pict, int, int) : bool`
- `sepia(pict) : pict`
- `blur(pict, float) : pict`
- `resize(pict, int, int) : pict`
- `crop(pict, int, int, int, int) : pict`

A runtime with implementations (in C) of all of these functions will
be provided to you, with the following signatures:

```
#include <stdint.h>

struct pict {
    int rows;
    int cols;
    double *data;
};

int64_t sub_ints(int64_t a, int64_t b);
double sub_floats(double a, double b);
int32_t has_size(struct pict input, int64_t rows, int64_t cols);
struct pict sepia(struct pict input);
struct pict blur(struct pict input, double radius);
struct pict resize(struct pict input, int64_t rows, int64_t cols);
struct pict crop(struct pict input, int64_t top, int64_t left, int64_t bottom, int64_t right);
```

Your compiler's output will call these provided implementations.

Your compiler must output code for the [NASM assembler][nasm]. That
assembly code must compile cleanly to an object file that defines the
function `main`; after compilation, the user will run NASM to assemble
the generated code, and link it with the provided runtime to produce a
finished executable.

[nasm]: https://www.nasm.us/

Besides the functions provided above, the runtime also provides these
functions:

```
struct pict read_image(char *filename);
void print(char *text);
void write_image(struct pict input, char *filename);
void show(char *typestring, void *datum);
void fail_assertion(char *text);
double get_time(void);
```

You are expected to use them to implement JPL's various commands and
statements.

## Type Checking in JPL subset

With only four types, type checking JPL is pretty simple. You will
need to define a class for types, containing the four types above plus
function types; a function type stores a list of types for the
function's arguments, plus a return type. This will allow you to
construct a *symbol table*, which maps variable and function names (as
strings) to types.

Next, you must define two functions:

- `type_expr` takes an `Expr` AST node and a symbol table, and either
  terminates the program (on a type error) or returns the type of the
  expression. Type errors only occur if the arguments to a function
  have the incorrect type, or if an undefined variable or function is
  used, or if a normal variable is used as a function, or if a
  variable or function name is reused.

- `type_stmt` takes a `Stmt` AST node and a symbol table, and either
  terminates the program (on a type error) or returns nothing after
  modifying the symbol table. Type errors occur for `assert` with a
  non-`bool` argument, `write image` with a non-`pict` argument, and
  `return` with a non-`int` argument. They also occur for `let` and
  `read image` when a variable is redefined.

Note that `show` works on any type so it never raises a type error.

Modify your `Expr` AST node to add a field for types. Modify
`type_expr` to save the type it returns to the AST node it was type
checking.

## Flattening the JPL subset

Flattening refers to replacing deeply-nested ASTs with shallow ones by
adding more `let` statements. This is an extremely common technique
that is implemented in almost all compilers. Its purpose is to take
complex syntactical forms that appear in the source language, and to
turn them into simpler forms that are easier for the rest of the
compiler to process. For example, flattening the following expression:

    read image "in.png" to img
    time write image resize(crop(sepia(img), 50, 250, 650, 650), 300, 200) to "out.png"

would produce:

    read image "in.png" to img
    let t.0 = time()
    let t.1 = sepia(img)
    let t.2 = 50
    let t.3 = 250
    let t.4 = 650
    let t.5 = 650
    let t.6 = crop(t.1, t.2, t.3, t.4, t.5)
    let t.7 = 300
    let t.8 = 200
    let t.9 = resize(t.6, t.7, t.8)
    write image t.9 to "out.png"
    let t.10 = time()
    let t.11 = sub_floats(t.10, t.0)
    show t.11
    print "write image resize(crop(sepia(img), 50, 250, 650, 650), 300, 200) to 'out.png'"
    let t.12 = 0
    return t.12

Specifically, flattening a type-correct JPL program from this
assignment's subset must result in a type-correct JPL program, also in
the same subset, which satisfies these additional constraints:

- Every argument to a function is a variable reference
- Every argument to `assert`, `return`, `show`, or `write image` is a
  variable reference.
- There are no `time` commands; those are expanded to `time`,
  `sub_float`, `show`, and `print`
- There is exactly one `return` command, and it is the last command in
  the list. If the input program had more than one `return`, drop all
  commands that come after it; if it did not have a `return`, add `let
  t.N = 0; return t.N` to the end of the program.

Note that this requires introducing new variable names. We strongly
recommend naming your new variables `t.N`, where `N` is the value of a
global counter that counts up from 0. This guarantees that these
variables will not clash either with each other or with variable names
chosen by the user.

When converting `time` commands to `print` arguments, you'll run into
a small problem because in JPL the string argument to `print` cannot
contain double quotes. It's acceptable to replace double quotes with
single quotes to circumvent this.

Make sure that the flattened JPL you generate is type-correct. We
recommend re-type-checking the flattened output and crashing your
compiler if it does not type check. This will catch a lot of bugs.

Flattening should be a single function that takes a list of commands
and a symbol table as input, and produces a list of commands as
output. Additionally, it should update the symbol table to reflect the
new variables that it introduced. Flattening should never crash on a
type-correct JPL program from this assignment's subset.

## Code generation

The first stage of code generation is planning the stack frame.

Compute the total size of all variables in the symbol table; treat
functions in the symbol table as taking up 0 bytes. This total is the
size of the stack frame; store this in a variable.

Create a data structure to map variable names (as strings) to
locations in the stack frame (as integers). Iterate through your
symbol table and assign a location to each variable, in order, making
sure to give each variable as much space as its type requires. For
example, the the flattened code above defines:

| Var      | img  | t.0    | t.1  | t.2  | t.3  | t.4    |
|----------|------|--------|------|------|------|--------|
| Type     | pict | double | pict | pict | pict | double |
| Size     | 24   | 8      | 24   | 24   | 24   | 8      |
| Location | 24   | 32     | 56   | 80   | 104  | 112    |

The total size of the stack frame in this case is 112 bytes. Note that
locations do not start at 0. This is because the stack grows down.

On macOS, the stack frame has to be a multiple of 16 bytes in size.
Pad it if necessary.

With the stack frame planned out, you must generate the function
prologue, then output code for each commands in the program in order,
and then generate the function epilogue.

## Storing Constants

Output the assembly code:

    global _jpl_code
    extern TODO
    
    section .data

Next you must gather all the integer, float, and string constants in
your program. These are placed in the "data section" of the assembly,
and later on when the program actually uses those constants they're
loaded from the data section.

Each constant must be given a name; store that name somewhere so you
can recall it later, when the constant is used. One way to do that is
to have a hash table that maps AST nodes to names.

Then output a constant definition for each constant, as described in
our [Assembly Handbook](../assembly.md).

## Generating code

Output the assembly code:

    section .text

With the stack frame planned out, you must generate the function
prologue, then output code for each commands in the program in order,
and then generate the function epilogue. After flattening, the JPL
program is a shallow list of commands, with one of the following
forms:

- A `let` statement with an integer or floating point constant
- A `let` statement with a variable reference
- A `let` statement with a function call where all arguments are variables
- An `assert` statement with a variable reference
- A `read image` command
- A `write image` command with a variable reference
- A `print` command
- A `show` command with a variable reference
- A `return` statement with a variable reference

Each of the types of commands has its own assembly snippet that must
be produced, described in the [Assembly Handbook](../assembly.md) in
the root of this directory.

If you follow the instructions in our "Assembly Handbook" carefully,
your code should work. And what "work" means is a little involved.
Your compiler is expected to ensure that:

- The compiler, run with the `-s` flag, returns successfully and
  outputs a bunch of assembly code and a single line with the words
  `Compilation successful` at the beginning.
- The NASM assembler then successfully assembles the code into an
  object file and produces no console output.
- The linker then successfully links the object file and the runtime
  into an executable and produces no console output.
- The resulting executable runs and produces the expected output and
  return code, without triggering any kind of fault condition (like a
  segmentation fault). It also does not trigger any unexpected effects
  (accessing the wrong files, for example).

Because there are lots of ways to go wrong, you'll be doing a lot of
debugging, at several different levels.

## Debugging Assembly

*This will be a challenging assignment.* One of the biggest challenges
during code generation is debugging the emittted assembly language. We
offer the following suggestions:

**Time**: Plan on spending a lot of time debugging. Start very early
on this assignment.

**Incrementalize**: Practice incremental development to the maximum
extent possible. Get something small and simple to work, and test it
thoroughly, before moving on. The code generation tests are ordered by
difficulty for this reason; it is a good idea to start at `001.jpl`
and not to move on until it works.

**Bisect**: Always start by narrowing the issue to the relevant part
of the compiler. Check the type-checked tree, the flattened output,
and the assembly code, so you know which stage went wrong. Keep stages
strictly separated (keep all assembly logic separate from all
flattening logic) so it's easy to debug. You can add extra compiler
flags to output additional information (like the stack layout).

**Common Issues**: The [Assembly Handbook](../assembly.md) lists some
common issues and how to fix them. Often the best way to understand a
problem is to narrow it down to the relevant assembly snippet (easy if
you are working incrementally!) and then compare it to the recommended
output.

**Tools**: Use a tool for interactive debugging of assembly language
programs. The important features are inspecting the machine state
(memory, registers, and processor flags) and executing a single
instruction at a time. The default tool for this job is the
interactive debugger `gdb`. The [Assembly Handbook](../assembly.md)
has links to some debugger tutorials.

**References**: Keep a couple of references for both x86-64
instruction set and the NASM assembler specifically handy while you
are working. You can find lists of both in the [Assembly
Handbook](../assembly.md).

## CHECKIN Due February 26

The checkin part of this assignment is intended to assist you in
eliminating as many bugs as possible in your name resolution, type
checking, and flattening code before you move on to code generation.

This checkin will be very much like the handin part of Assignment 2,
in the sense that you will emit s-expressions representing your parse
tree. There are two pieces:

  1. Your compiler should implement a `-t` command line option which
     causes it to stop after typechecking and print s-expressions
     (similar to those you printed for the handin part of Assignment
     2) that include type information as specified below.

  2. Your compiler should implement a `-f` command line option which
     causes it to stop after flattening and print s-expressions.
     Again, these should be annotated with types.


## HANDIN Due March 5


The handin expects you to have a complete compiler for the JPL subset
of interest, which emits NASM assembly code. Specifically your
compiler should implement a `-s` command line option which causes it
to generate assembly code and print it to the standard output. That
assembly code must be correct as described above---it must pass NASM,
the linker, and run cleanly, producing the expected output.

To help you in this task, we are providing the `test-assembly.pl`
script. It runs your compiler on a set of tests (in
`tests/assembly/*.jpl`) ordered by difficulty; for each test it runs
your compiler and compares the generated assembly code to code
produced by our compiler (in `tests/assembly/*.s`). While you are not
required to match this assembly exactly, it'll be easiest for you if
you do. Comparing your generated assembly to the recommended assembly
is likely the fastest way for you to find issues in your compiler.
The tests are ordered by difficulty, and we recommend not moving on to
a later test until every earlier test is done; to that end the test
script will stop on the first failure.

After you have assembly generation working, run `test-codegen.pl`.
This script runs your compiler, assembles the resulting assembly,
links it, and runs it. This script will use a larger set of tests than
`test-assembly.pl`, so it's possible to fail this script after passing
that one, but that should be unlikely. We strongly recommend not
trying this until the previous test works: running malformed assembly
is dangerous in a way looking at it isn't, and comparing diffs of the
assembly code is way easier than using a debugger to step through a
bad executable.

As always, even if the tests pass on your computer, or some other
computer, it does not count unless those tests also pass on a CADE
Linux machine. Since this is a hard requirement, please test it out
well before the due date so you have time to resolve any problems that
may come up. On CADE, you will want to use the `elf64` format for NASM.
