Assignment 9: Generating Assembly
=================================

For this assignment you will start generating assembly code, starting
with basic expressions.
 
## Function and type definitions

In this assignment, you will begin generating x86\_64 assembly code
from JPL. Specifically, you will add generate code for the following
syntactic constructs:

```
cmd : show <expr>

expr : <integer>
     | <float>
     | true
     | false

expr : - <expr>
     | ! <expr>
     | <expr> + <expr>
     | <expr> - <expr>
     | <expr> * <expr>
     | <expr> / <expr>
     | <expr> % <expr>
     | <expr> < <expr>
     | <expr> > <expr>
     | <expr> == <expr>
     | <expr> != <expr>
     | <expr> <= <expr>
     | <expr> >= <expr>
     
expr : { <expr> , ... }
     | [ <expr> , ... ]
     | <expr> { <integer> }
```

Note that the expressions are organized into three groups, from
easiest to hardest. Consult the [JPL specification](../spec.md) for
the expected behavior of these constructs.

Your compiler must implement the `-s` flag and print `Compilation
failed` or `Compilation succeeded` when compiling. We will use this
when testing your compiler.

## Learning assembly

The compiler you write for this assignment must produce the same
assembly output as the provided JPL compiler, available in the
"[Releases][releases]" tab for this repository. This means that you
don't have a lot of flexibility in terms of what assembly to produce;
which is going to be be a bit of a pain, but which will also save you
quite a bit of difficult debugging.

[releases]: https://github.com/utah-cs4470-sp23/class/releases

That said, learning to read and understand assembly *is* a goal of
this assignment. We've written an [Assembly Handbook](../assembly.md),
which describes all of the assembly syntax and instructions you need
to know. It also has lots of other information, like how to link and
run assembly code. You should read it. However, the Assembly Handbook
doesn't fully spell out how every single JPL expression should be
compiled---to determine that, you will need to use the provided JPL
compiler, examine and understand its output, and replicate the way it
compiles JPL. (Comments and empty lines will be stripped out, so you
don't need to replicate those.)

The way we recommend you go about this is to compile small programs
that demonstrate whatever feature you are working on and then examine
the assembly by hand. For example, as you start working on integer
constants, you might compile a program like this:

    show 73
    
By running:

    $ ./jplc -s test.jpl

This will produce the following assembly (linking and constants
elided):


    jpl_main:
    _jpl_main:
    	push rbp
    	mov rbp, rsp
    	push r12
    	mov r12, rbp
    	mov rax, [rel const0] ; 73
    	push rax
    	lea rdi, [rel const1] ; (IntType)
    	lea rsi, [rsp]
    	call _show
    	add rsp, 8
    	pop r12
    	pop rbp
    	ret

Reading this, you might be able to identify the function prologue and
epilogue (the first two and last two instructions inside the
function). Then the first two instructions after the prologue load the
constant 73 into a register and push it onto the stack, so that's got
to be how integer constants work. So the rest of it must be the `show`
command. You can add comments to help yourself keep track of this:

    _jpl_main:
        ; Prologue
    	push rbp
    	mov rbp, rsp

        ; Set up R12 to point to global variables
    	push r12
    	mov r12, rbp

        ; (IntExpr 73)
    	mov rax, [rel const0] ; 73
    	push rax

        ; (ShowCmd (IntType) ...)
    	lea rdi, [rel const1] ; (IntType)
    	lea rsi, [rsp]
    	call _show

        ; pop the "73" off the stack
    	add rsp, 8

        ; Restore R12 from before the call
        pop r12

        ; Epilogue
    	pop rbp
    	ret
        
Especially when you don't know assembly very well, it can also be
helpful to run the program under a debugger so that you can step
instruction by instruction. GDB and LLDB are popular debuggers.
Debuggers have a _lot_ of features but the Assembly Handbook covers
the most basic operations: stepping through the program one by one;
printing register values; and examining memory. So for example, if
you're interested in the `call _show` instruction above, you might run
the program above under a debugger, step to that instruction, and
examine the RDI, RSI, and RSP registers. (If you're using GDB instead
of LLDB, your output will look different in superficial ways; and of
course, the actual memory addresses will differ on each machine.)

    (lldb) p/x $rdi
    (unsigned long) $1 = 0x0000000100008148
    (lldb) p/x $rsi
    (unsigned long) $2 = 0x00007ff7bfeff768
    (lldb) p/x $rsp
    (unsigned long) $3 = 0x00007ff7bfeff760

You can see that the stack pointer ends in a `0`, meaning it's aligned
to 16 bytes---that explains the `sub` and `add` instructions with
comments about alignment. Furthermore, looking at these values, you
might guess that RSI is a pointer to the stack, while RDI is a pointer
into the binary. And we could examine memory at those locations:

    (lldb) x $rdi
    0x100008148: 28 49 6e 74 54 79 70 65 29 00 00 00 00 00 00 00  (IntType).......
    0x100008158: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    (lldb) x $rsi
    0x7ff7bfeff768: 49 00 00 00 00 00 00 00 80 f8 ef bf f7 7f 00 00  I...............
    0x7ff7bfeff778: 2e 55 01 00 01 00 00 00 00 00 00 00 00 00 00 00  .U..............
    
So you can tell that `show` is being called with RDI pointing to a C
string (it is even null terminated!) containing `(IntType)`, while RSI
is pointing to the integer constant `0x49` which is 4 * 16 + 9 = 73.
Recalling that the x86_64 calling convention puts the first argument
in RDI and the second argument in RSI, you can see this as basically
the equivalent of `show("(IntType)", &73)` in C.

As always, do feel free to ask for help or discuss questions on
Discord. It is never cheating to discuss the output of the provided
compiler!

## General conventions

In general, every kind of expression for this assignment generates a
single block of assembly instructions. This block of assembly expects
the values of all of its subexpressions on the stack, pops them off
the stack, and pushes the value it computes back on the stack.
Stack values are referred to via positive offsets from RSP.

Every expression's assembly code assumes nothing about the values of
the registers (other than the stack registers), so each assembly block
works in a stand-alone way. In general, the assembly code only uses
callee-saved registers (except for RSP and RBP), so, when calling
functions you have to assume that any register values could have been
changed.

The assembly code generated by your compiler is intended to be linked
against a runtime. The [runtime][runtime] documentation covers what
the runtime functions do, in detail, but you may need to read the
runtime source code to answer some questions you have.

[runtime]:https://github.com/utah-cs4470-sp23/runtime 

During code generation, it is essential to check for possible runtime
errors. Different kinds of errors require different handling, and it's
important to think these through:

- Some errors, like tuple indexing with too-large an index, will be
  caught and prevented by the type checker, so you don't need to think
  about them.
- Some errors, like a failure to allocate memory in `malloc`, will be
  caught by the runtime and cause your program to exit cleanly. The
  runtime documentation describes the behavior of the runtime; you
  don't need to think about these errors, either.
- Some errors, like division by zero, have to be caught by the
  assembly code you generate. When a failure occurs, you should call
  the `fail_assertion` runtime function with an appropriate error
  message.
- When constructing an array literal, you need to multiply the number
  of elements by the size of the element to get the number of bytes to
  allocate. You _must_ check for overflow when you do the multiply.
  The the multiply happens during code generation, you won't see that
  check in the assembly code, but you must do it.

Note that in general, floating-point operations _do not_ cause errors.
Dividing by floating-point zero, for example, results in an infinite
or NaN value, not an actual error. Integer operations, on the other
hand, do cause errors.

## Organizing your assembler

Much like your type checker or your parser, your code generator will
consist of a collection of functions that call each other recursively.
It's recommended that you organize these functions under a
`Function` class, and define one function for every AST class
(functions called `cg_expr`, `cg_cmd`, and so on, where `cg` stands
for "code generate") and another one for every AST node type
(functions called `cg_intexpr`, `cg_binopexpr`, and so on).

Each of these functions should take two inputs---the AST node in
question, and a description of the stack (which you can think of as
similar to the symbol table in your type checker)---and produce a two
outputs---a sequence of assembly instructions, and a new description
of the stack. They should start by recursively calling `cg_expr` on
each subexpression in reverse order (so that the first subexpression
is on top of the stack, meaning earlier in memory), and then combine
those assembly blocks, tacking on the function-specific assembly to
the end.

As you generate code for various expressions, you will also need to
add constants, labels, and linkage commands. These go in a different
part of the assembly code, so we recommend storing the constants and
linkage commands in separate fields of a separate `Assembly` and
writing helper methods like `add_extern` or `add_float` to add to
those fields. These helper methods will need to also increment
counters so that you can give a unique name to each constant or label.
The `Assembly` would also store a list of `Function`s and convert all
of this data into an assembly source code string.

You will need to write a recursive function that computes the size, in
bytes, of a given `ResolvedType`. (For example, you'll need to know
this to allocate the correct amount of memory for an array literal.)

# Testing your code

Your code will be tested against the provided JPL compiler. You will
need to update your compiler, since earlier versions did not have
compilation enabled. You can update your compiler by navigating to
your checkout of the auto-grader repository and running:

    make -C <auto-grader directory> upgrade
    
Naturally, this JPL compiler is a program and can have bugs. If you
think you've found one, contact the instructors on Discord.

Note that the auto-grader normalizes initial whitespace, newlines,
comments, and math before comparing assembly files. This means you
probably want to run the provided compiler on your own instead of just
using the auto-grader to figure out what assembly you're supposed to
produce. When run directly, the provided compiler prints some
comments, indents some stuff, and in general is easier to read.

You can find the tests and expected outputs [in the auto-grader
repository](https://github.com/utah-cs4470-sp23/grader/tree/main/hw9).

The directories `ok1` (Part 1, `show`), `ok2` (Part 2, arithmetic),
and `ok3` (Part 3, data structures) contain valid hand-written JPL
programs to guide you through this assignment.

The `ok-fuzzer` (Part 4) directory contains valid, auto-generated JPL
programs.

You can run these tests on your computer by downloading the
auto-grader and running it like so:

    make -C <auto-grader directory> DIR=<compiler directory> PART=<part>

We recommend trying to get each part working fully before moving on to
the next one.

# Submission and grading

This assignment is due Friday March 17.

We are happy to discuss problems and solutions with you on Discord, in
office hours, or by appointment.

Your compiler must be runnable as described in the [Testing your
code][Testing your code] section. If the auto-grader cannot run your
code, you will not receive credit. The auto-grader output is available
to you at any time, as many times as you want. Make use of it.

The rubrik is:

| Weight | Function |
|--------|----------|
| 15%    | Part 1   |
| 20%    | Part 2   |
| 15%    | Part 3   |
| 50%    | Part 4   |

Your solutions will be auto-graded. The auto-grader will use Github
Actions and runs on Ubuntu using the tests described above.
