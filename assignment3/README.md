# DO NOT READ. Assignment is unfinished and also extremely scary.

# Assignment 3: Parsing Commands and Statements

Your third assignment is to build a compiler for the subset of JPL
that you implemented a parser for in Assignment 2. This compiler's job
is to turn an AST into:

- an assembly function, or
- a type error.

You will be implementing this compiler in three steps:

- Type checking
- Flattening
- Code generation

Recall that the subset of JPL that we are working with contains
variable of just four types: `bool`, `int`, `float`, and `int[,]`
which we will refer to in this assignment as `pict`. The four types
correspond to the following types in C, all provided by the
`<stdint.h>` header:

- `bool` corresponds to `int32_t` and takes up 4 bytes
- `int` corresponds to `int64_t` and takes up 8 bytes
- `float` corresponds to `double` and takes up 8 bytes
- `pict` corresponds to `struct { int64_t; int64_t; double *; }`
  and takes up 24 bytes

Expressions in this subset are either constants, or they are a call to
one of the following functions:

- `has_size(pict, int, int): bool`
- `sepia(pict): pict`
- `blur(pict, float) : pict`
- `resize(pict, int, int): pict`
- `crop(pict, int, int, int, int): pict`

A runtime with implementations (in C) of all five functions will be
provided to you, with the following signatures:

```
#include <stdint.h>

struct pict {
    int rows;
    int cols;
    double *data;
};

int32_t has_size(struct pict input, int rows, int cols);
struct pict sepia(struct pict input);
struct pict blur(struct pict input, double radius);
struct pict resize(struct pict input, int64_t rows, int64_t cols);
struct pict crop(struct pict input, int64_t top, int64_t left, int64_t bottom, int64_t right);
```

Your compiler's output will call these provided implementations.

Your compiler must output assembly code for the NASM assembler. That
assembly code must compile cleanly to an object file that defines the
function `main`; after compilation, the user will run NASM to assemble
the generated code, and link it with the provided runtime to produce a
finished executable.

Besides the functions provided above, the runtime also provides these
functions:

```
struct pict read_image(char *filename);
void print(char *text);
void write_image(struct pict input, char *filename);
void show(char *typestring, void *datum);
void abort(char *text);
double time(void);
double time_since(double);
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
  used, or if a normal variable is used as a function.

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
adding more `let` statements. For example, flattening the following
expression:

    read image "in.png" to img
    time write image resize(crop(sepia(img), 50, 250, 650, 650), 300, 200) to "out.png"

would produce:

    read image "in.png" to img
    let t.0 = time()
    let t.1 = sepia(img)
    let t.2 = crop(t.1, 50, 250, 650, 650)
    let t.3 = resize(t.2, 300, 200)
    write image t.3 to "out.png"
    let t.4 = time_since(t.0)
    show t.4
    print "write image t.3 to 'out.png'"

Specifically, flattening a type-correct JPL program from this
assignment's subset must result in a type-correct JPL program, also in
the same subset, which satisfies these additional constraints:

- Every argument to a function is an integer constant, float constant,
  or a variable reference
- Every argument to `assert`, `return`, `show`, or `write image` is a
  variable reference.
- There are no `time` commands; those are expanded to `time`,
  `show_time`, and `print` calls.
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

With the stack frame planned out, you must generate the function
prologue, then output code for each commands in the program in order,
and then generate the function epilogue.

The function prologue is the following sequence of assembly commands:

	pushq	%rbp
	movq	%rsp, %rbp
	subq	$XXX, %rsp

where `XXX` is the total size of the stack frame, **plus 24**. The function
epilogue is the following sequence of assembly commands:

	addq	$XXX, %rsp
	popq	%rbp
	retq

Here `XXX` is again the total size of the stack frame **plus 24**. The
function prologue and epilogue are perfect mirrors and must match.

Second, you must gather all the strings across all commands in the
program, and generate assembly for them. For each string, the assembly
looks like this:

    .section	___TEXT
    stringN: .asciz "STRING CONTENTS\0"

Here `STRING CONTENTS` refers to the contents of the string and `N`
refers to a new counter for strings. Make sure to add the `\0` at the
end. Create a map from string constants to their numbers `N`.

Each of the types of commands has its own assembly snippet that must
be produced. After flattening, the JPL program is a shallow list of
commands, with one of the following forms:

- A `let` statement with an integer or floating point constant
- A `let` statement with a variable reference
- A `let` statement with a function call
- An `assert` statement with a variable reference
- A `read image` command
- A `write image` command with a variable reference
- A `print` command
- A `show` command with a variable reference
- A `return` statement with a variable reference

A `let` statement with an integer or floating point constant
corresponds to the following assembly:

	movq	$XXX, -YYY(%rbp)

Here `XXX` is the actual constant value (as an integer) and `YYY` is
the location corresponding to the variable on the left hand side of
the `let`.

A `let` statement with a variable reference corresponds to the
following assembly:

	movq	-XXX(%rbp), %rbx
	movq	%rbx, -YYY(%rbp)

Here `XXX` is the location of the variable on the right hand side and
`YYY` is the location of the variable on the left hand side.

An `assert` statement with a variable reference corresponds to the
following assembly:

	cmpq	-XXX(%rbp), 0
    jnz	skipN
    movq	stringM(%rip), %rdi
    call	_abort
    skipN:

Here, `XXX` is the location of the variable in the assertion, `N` is a
new counter for assertions, `M` is the number for the string constant
in the assertion.

A `return` statement with a variable reference corresponds to the
following assembly:

	movq	-XXX(%rbp), %rax

Here `XXX` is the location of the variable.

All other commands are basically function calls, so let's finally
discuss how to generate assembly for those.

A function call has some number of arguments and one output.

All arguments except floats are passed in registers, specifically the
registers `rdi`, `rsi`, `rdx`, `rcx`, `r8d`, and `r9d`, in that order.
Float arguments are passed in `xmm0`, `xmm1`, `xmm2`, `xmm3`, `xmm4`,
`xmm5`, `xmm6`, and `xmm7`. No function in JPL passes so many
arguments that you need to worry about what to with extra ones. If the
function returns `pict`, it will have an extra integer argument as its
first argument.

How exactly each argument is handled depends on their type: `int`,
`bool`, `float`, `pict`, or strings.

`int` arguments are moved to their destination register with this bit
of assembly for variable arguments:

    movq -XXX(%rbp), REG

where `XXX` is the location of that integer argument and `REG` is the
destination register, or for constants:

    movq $XXX, REG
    
where `XXX` is the value of the constant.

`bool` arguments are moved to their destination register like so:

    movl -XXX(%rbp), %ebx
    movq %rbx, REG

`float` arguments are moved to their destination register like so:

???

String arguments are moved to their destination register like so:

    movq	stringM(%rip), REG

Here `M` is the number for that string.

`pict` arguments are passed like so:

	leaq	-XXX(%rbp), %rbx
	movq	(%rbx), %rax
	movq	%rax, (%rsp)
	movq	8(%rbx), %rax
	movq	%rax, 8(%rsp)
	movq	16(%rbx), %rax
	movq	%rax, 16(%rsp)

Here `XXX` is the locaton of the `pict` argument. Note that there is
no `REG` in this block. `pict` arguments do not take up a register
because they are passed on the stack. If you know a bit of assembly,
you can see that this copies 24 bytes from the location of the `pict`
argument to the top of the stack.

To call the function, use the assembly:

    callq	_FNNAME
    
Here, `FNNAME` is the name of the function

After the function returns, if it returns an `int` or `bool`, you can
move that output to its location using the following assembly:

    movq	%rax, -XXX(%rbp)

If it returns a `float`, move it to its location like so:

???

If it returns a `pict` argument, however, that actually means the
function had an extra first argument, which you must set like so
before calling the function:

	movq	-XXX(%rbp), %rdi

Since it's a first argument, it always takes up the `rdi` register.
Don't get this wrong.

## Debugging Assembly

One of the primarily challenges your will face during code generation
is debugging the emittted assembly language. We offer the following
suggestions:

1. Plan on spending a lot of time debugging. Start very early on
this assignment.

2. Practice incremental development to the maximum extent possible.
In other words, get something small and simple to work, test it
thoroughly, and repeat.

3. Find and use a tool for interactive debugging of assembly language
programs. The important features are inspecting the machine state
(memory, registers, and processor flags) and executing a single
instruction at a time. The default tool for this job is the
interactive debugger `gdb`. Here is the [gdb
documentation](https://www.gnu.org/software/gdb/documentation).
Various GUI front-ends for gdb are available if you prefer a
non-command-line debugging environment. Here are some quick tutorials
on using the assembly-relevant parts of gdb:

    * <https://www.cs.umb.edu/~cheungr/cs341/Using_gdb_for_Assembly.pdf>
    * <https://www.cs.swarthmore.edu/~newhall/cs31/resources/ia32_gdb.php>
    * <https://web.cecs.pdx.edu/~apt/cs491/gdb.pdf>

4. Keep a couple of references for x86-64 assembly language handy
while you are working.
      * Here are some short, quick guides:
        - <https://khoury.neu.edu/home/ntuck/courses/2018/09/cs3650/amd64_asm.html>
        - <http://www.cs.cmu.edu/afs/cs/academic/class/15213-s20/www/recitations/x86-cheat-sheet.pdf>
      * These are a bit longer and more detailed:
        - <https://software.intel.com/content/dam/develop/external/us/en/documents/introduction-to-x64-assembly-181178.pdf>
        - <https://www.cs.tufts.edu/comp/40/docs/x64_cheatsheet.pdf>
      * And finally, this is the definitive guide:
        - <https://software.intel.com/content/www/us/en/develop/download/intel-64-and-ia-32-architectures-sdm-combined-volumes-1-2a-2b-2c-2d-3a-3b-3c-3d-and-4.html>

5. Implement an optional debug mode in your compiler where it prints
details about what it is thinking about at various stages of the
compilation job.
