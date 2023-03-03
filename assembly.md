# x86_64 Assembly Handbook for your JPL compiler

You will be using an assembler called NASM. We picked this assembler
because it is user-friendly (compared to other assemblers) and
cross-platform. It has [nice tutorials][tutorial] and a [comprehensive
manual][manual].

[tutorial]: https://cs.lmu.edu/~ray/notes/nasmtutorial/
[manual]: https://nasm.us/doc/nasmdoc0.html

# Using the tools

You can assemble some assembly code like this:

    nasm -fXXX code.s

Here, `XXX` is the name of your object file format. On Linux or WSL,
that'll be `elf64`, on macOS `macho64`, and on native Windows `win64`.
*Don't forget the "64".* Assembling produces a `code.o` object file.
You then need to link it, like this:

    ld code.o runtime.a -lpng -lm

The `runtime.a` in this case is the compiled JPL runtime, [provided
separately][runtime], and you can use `clang` or `gcc` instead of `ld`
if you don't have an `ld` command. Consult the JPL runtime
documentation for more details.

[runtime]:https://github.com/utah-cs4470-sp23/runtime 

This command will produce a file called `a.out`, short for "assembler
output". (Even though it is not actually output by your assembler...)
You can run that file:

    ./a.out

Here are some common error messages:

- `impossible combination of address sizes`: You forgot the "64" at
  the end of your NASM format flag. It should be, for example, `elf64`
  not `elf`.
- `symbol ... not defined`: You need to add an `extern` declaration
  for that function in the runtime.

It should run! If it doesn't, you'll need to debug. That will be hard.

## Debuggers

One way to do that is with a debugger like GDB or LLDB. You'll likely
need to install those separately; once you do, you can run:

    gdb ./a.out

This puts you in the debugger console. Debuggers have a *lot* of
features, but here are the most important ones for navigating through
a program's execution:

- The `b main` command sets a "breakpoint" at the start of the `main`
  method. This means your process will stop right before it executes
  the first instruction in `main`, and let you examine the state. You
  can likewise put in a different function name if you want to pause
  there.
- The `run` command runs the program, stopping at the first
  breakpoint. The `continue` command is similar, it unpauses the
  program and runs until the next breakpoint.
- The `stepi` command runs one x86_64 instruction.
- The `nexti` command runs one x86_64 instruction, unless that
  instruction is a `call`, in which case it runs until that call
  returns. (You might be familiar with "step over"; that's what this
  does.)
   
While the program is paused, you can look at its state. There are two
important commands here:

- The `p` command prints a register's value. For example, `p $rsp`
  prints the contents of the register RSP. You can change the format
  using a slash and a format specifier; for example, `p/x $rsp` prints
  the contents of the register RSP as hexadecimal. Other format
  specifiers include `d` for decimal integers, `f` for floating-point,
  and `s` for null-terminated ASCII strings.
- The `x` command prints the contents of memory. Its argument is an
  address. For example, `x $rsp` prints the contents of memory
  starting at RSP; in other words, it prints the (first part of) the
  stack. Like `p`, it takes a format specifier. You can also pass a
  number in front of a format specifier if you want to read multiple
  of that format; for example, `x/2f $rsp` prints the top two
  values on the stack as floating-point numbers.

Keep in mind that both tools use a different assembly syntax. You'll
figure most of the differences out on your own, but you may be
surprised to learn that they swap the arguments, with the destination
register coming last. Both allow you to configure the assembly syntax
if you'd like.

Here is the [GDB documentation][gdb-docs] and [LLDB
documentation][lldb-docs]. Various GUI front-ends for GDB are
available if you prefer a non-command-line debugging environment. Here
are some quick tutorials on using the assembly-relevant parts of GDB:

[gdb-docs]: https://www.gnu.org/software/gdb/documentation
[lldb-docs]: https://lldb.llvm.org/use/tutorial.html

- https://www.cs.umb.edu/~cheungr/cs341/Using_gdb_for_Assembly.pdf
- https://www.cs.swarthmore.edu/~newhall/cs31/resources/ia32_gdb.php
- https://web.cecs.pdx.edu/~apt/cs491/gdb.pdf

Here are some common assembly bugs:

- If you see `stack_not_16_byte_aligned_error` or an `E_BAD_ACCESS`,
  especially somewhere inside a system library, your stack size must
  be a multiple of 16 bytes before you call another function. Make it
  a little bigger to make it a multiple of 16 bytes.
- If you are trying to do something with strings, and are getting
  segmentation faults, make sure you used `lea` instead of `mov` to
  load the string constant into a register. `lea` puts the pointer of
  the string in the register, while `mov` instead copies the
  value---the first 8 characters. You can usually tell because one of
  your registers will have a lot of bytes that begin with 4 and 6
  (these are ASCII lower-case and upper-case letters).

If it's not these, ask for help.

# Syntax of Assembly Files

Your assembly files will have three sections: linkage information,
constants, and code.

## Linkage information

The linkage information consists of the `extern` and `global`
instruction. Think of `extern` like "import" and `global` like
"export". Your JPL compiler will `extern` functions like `print`,
`show`, and `fmod`, and it will `global` the `jpl_main` function.

When you `global` your `jpl_main`, do so twice, once with and once
without a prefix underscore:

    global jpl_main
    global _jpl_main
    
This will work whether or not you're on macOS, which has a weird
underscore convention. When you `extern` something, always use the
prefix underscore; our JPL runtime has been set up to make this work
on both macOS and other platforms.

## Constants

Next, your assembly file will have the line:

    section .data

Integer, floating point, and string constants are defined differently
in assembly. Here's a quick example:

    four: dq 4
    pi:   dq 3.1415926535897932384626433
    hewo: db `Hello, World!`, 0

Define integer and floating-point constants like this:

    NAME: dq VALUE

NASM will automatically convert the value to hex for you.

Define strings like this:

    NAME: db `VALUE`, 0

Here `NAME` is the name of the constant and `VALUE` is the original
value being stored. Note that for strings, you *must* include the
comma and the zero, which adds the null byte at the end. Also note
that you use backticks, not double quotes. Double quotes don't allow
backslash-escapes, while backticks do. You'll need to backslash-escape
backticks and backslashes.

## Code

The code portion of your assembly file will start with this line:

    section .text

Assembly code is a collection of functions. A function definition
looks like this:

    jpl_main:
    _jpl_main:
        <instructions here>

Naturally, you put the function's name instead of `jpl_main`. For
weird macOS reasons, always two labels for each function, one with and
one without a prefix underscore.

Inside the function body are instructions. The general form of an
assembly instruction looks like this:

    LABEL: INSTRUCTION WIDTH DESTINATION, ARGUMENT ; COMMENT
    
Labels are optional and name locations in the binary code. (This is how
"functions" work; they are nothing more than locations in the code.)
In NASM, it's best to start labels that aren't functions with a
period. This makes them "local" to that function.

Instructions come from the x86\_64 ISA. The comprehensive source is the
[Intel Manuals, Volume 2][intel-manuals], but the most convenient way
to look up an instruction is [Felix Cloutier's website][felix]. Here
are some short guides to x86\_64:

- https://khoury.neu.edu/home/ntuck/courses/2018/09/cs3650/amd64_asm.html
- http://www.cs.cmu.edu/afs/cs/academic/class/15213-s20/www/recitations/x86-cheat-sheet.pdf
- https://software.intel.com/content/dam/develop/external/us/en/documents/introduction-to-x64-assembly-181178.pdf
- https://www.cs.tufts.edu/comp/40/docs/x64_cheatsheet.pdf

If you look up information about x86\_64 online, make sure it's for
x86\_64! If it's for x86, that's probably fine too---a lot of those
websites are actually showing x86\_64 instructions, and even if
they're not, x86\_64 and x86 are very similar---typically the only
difference is that x86\_64 also does the same operations in 64 bits.
However, there's documentation out there on ARM assembly, PPC
assembly, and so on. Those will only confuse you.

When reading about assembly instruction, note that:

- If an instruction page says its argument is `r/m64` or `r64/m64`
  that means it can take either a regular register (but not an XMM
  register) or a memory location as an argument. If it says its
  argument is `xmm`, that means any `xmm` register (but not a regular
  register). If it says its argument is `imm64`, that means an
  "immediate", that is, an integer literal.
- If the manual refers to a "word", that means 16 bits. A
  "doubleword" is 32 bits. A "quadword" is 64 bits.
- If the manual refers to `RDX:RAX` or similar, that refers to a
  conceptual 128-bit integer whose first (most significant) 64 bits
  are in RDX and whose second (least significant) 64 bits are in RAX.
- If the manual refers to ZF, OF, or similar, those are references to
  specific flags, bits in the RFLAGS register.
- Each instruction has a half-dozen different forms, usually because
  it might support an argument that is a immediate or a register or a
  memory location, or because it might allow the same operation to
  happen at different widths, or similar. Typically, the instruction
  basically behaves the same in all variants, and the assembler will
  automatically infer which variant to use based on the arguments you
  supply. If you supply something impossible, it will complain.
- Some instructions have multiple names; for example, the
  [SETcc][setcc] instruction is one instruction but has variants like
  `SETLE`, `SETEQ`, and so on, depending on what comparison operation
  you want to do. You can tell because the instruction name will have
  lower-case letters.

[intel-manuals]: https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html
[felix]: https://www.felixcloutier.com/x86/
[setcc]: https://www.felixcloutier.com/x86/setcc

Instructions have an optional width. The width is usually inferred
from the operands so you should not need to specify it. Different
instructions have different numbers of operands, but the *destination*
register always comes first. Semicolons start a line comment.

Besides a register name, an argument can also be an "immediate" (which
in NASM you write as a decimal number) or an "indirect" location,
which refers to a memory location. The indirect location like `[rsp +
8]` refers to the memory location whose address is RSP plus 8 bytes.
x86_64 has some very fancy addressing modes like `[rdi + 8 * rsp +
16]`, but we wont' use them.

# The x86 Registers and Memory Layout

x86_64 CPUs have 16 integer registers and 8 floating point registers
that you can access directly. All are 64 bits wide. We will be using
them like this:

- `rsp`: The stack pointer, which delimts the end of the stack
- `rbp`: The base pointer, which delimits the start of the stack
- `rax`: The register containing integer return values and which we'll
  use as the main register for various stuff
- `r10`, `r11`: Other registers that we'll use
- `r12`: We'll use this to store a pointer to the global frame
- `xmm0` through `xmm7`: Floating-point registers

On x86_64 the top of the stack is pointed to by `rsp`. Generally
speaking `rbp` is used to point to the other end of the current stack
frame (the part of the stack that's for the currently executing
function). Usually local variables are referenced relative to `rbp`.
The stack grows *down*, so `rsp <= rbp` and you *subtract* from `rsp`
to add more to the stack.

The RSP and RBP registers are callee-saved, meaning each function has
to save and restore them, like so:

    function:
    _function:
    	push    rbp
    	mov     rbp, rsp
        ...
	    pop     rbp
	    ret

The R12 register is also callee-saved, so in the `jpl_main` function
we'll need to save it like so:

    jpl_main:
    _jpl_main:
    	push    rbp
    	mov     rbp, rsp
        push    r12
        ...
        pop     r12
	    pop     rbp
	    ret

In other functions, we just won't touch R12, so we won't need to save it.

The RAX, R10, R11, and other registers are caller-saved, meaning that
when you call a function, you should assume that those registers have
been wiped.

# Instructions

## Pushing, popping, and copying

You can load an integer, boolean, or floating-point constant into RAX
like so:

    mov rax, [rel NAME]

Here `NAME` is the constant's name. You might want to add a comment
with the constant's value as well. Then you can push RAX on the stack
like so:

    push rax
    
You can pop an integer or boolean value from the stack into RAX like
so:

    pop rax

There's no way to pop a floating-point value from the stack into an
XMM register, so you have to do this:

    movsd xmm0, [rsp]
    add   rsp, 8

Similarly, there's no instruction to push XMM onto the stack, but you
can do:

    sub   rsp, 8
    movsd [rsp], xmm0

Recall that subtracting from RSP *grows* the stack and that adding to
RSP *shrinks* the stack.

If you have two integer arguments, you can pop one into `rax` and one
into `r10`. If you have two floating-point arguments, you'll do
something like this:

    movsd xmm0, [rsp]
    movsd xmm1, [rsp + 8]
    add   rsp, 16
    
Larger objects, like tuples or arrays, can't be moved directly into a
register, since they are too big. However, they can be copied piece by
piece, like so:

    mov r10, [rsp + 16]
    mov [rax + 16], r10
    mov r10, [rsp + 8]
    mov [rax + 8], r10
    mov r10, [rsp + 0]
    mov [rax + 0], r10

This copies 24 bytes from `[rsp]` to `[rax]` via `r10`. Note that you
can't move from memory to memory. The data has to stop over in a
register, R10. Also note that we do the copy backwards---the furthest bytes
first. This is because we will typically copy "up" the stack, and
copying the highest bytes first means we won't overwrite our input
with our output.

## Arithmetic

You can negate an integer with:

    neg rax

You can negate a boolean with:

    xor rax, 1

There's no instruction to negate a boolean, and many good ways to do
so. We'll use the following ugly-but-clear method:

    pxor  xmm0, xmm0
    subsd xmm0, xmm1

Note that here we require the argument to be in XMM1, not XMM0. The
result ends up in XMM0.

You can add, subtract, or multiply integers with:

    add  rax, r10
    sub  rax, r10
    imul rax, r10

These operations handle overflow in exactly the way JPL expects.

You can add, subtract, multiply, and divide floats with:

    addsd xmm0, xmm1
    subsd xmm0, xmm1
    mulsd xmm0, xmm1
    
Dividing and modulus is harder. You divide and modulus integers like
so:

    mov  rdx, 0
    idiv r10

This is a bit confusing. The input is expected in RAX. However, `idiv`
considers its input RDX:RAX, a 128-bit number, so we zero our RDX.
Then, we divide by the denominator, R10; note that RAX is not
mentioned. The result of the division is stored in RAX, while the
modulus is stored in RDX, so in a modulus operation, you may need to:

    mov rax, rdx

When doing an integer division or modulus, you need to check whether
the denominator is zero. Do so like this:

    cmp r10, 0
    jne .BAD
    lea rdi, [rel ERROR_MESSAGE]
    call _fail_assertion
    .BAD:

This code compares the denominator, R10, to 0. If they are not equal,
it skips to the next thing (presumably a division or modulus) but if
they are equal, it loads the *address of* a string constant containing
an error message and calls the runtime's `fail_assertion`  method.

The `ERROR_MESSAGE` constant should be defined in the constant part of
the assembly file to containt a C string. The `BAD` jump should have a
unique name each time it's used.

Dividing floats is easy:

    divsd xmm0, xmm1

However, there's no instruction for float modulus, so we will call the
`math.h` function `fmod`:

    call _fmod

This functions takes two arguments in XMM0 and XMM1, and puts its
result in XMM0. You don't need to check for zero when doing float
division or modulus, because in JPL that's not an error.

## Comparisons

Comparing integers and booleans is easy; it always takes this form:

    cmp   rax, r10
    setXX al
    and   rax, 1

Here the `XX` refers to one of six instructions: `SETL`, `SETG`,
`SETLE`, `SETGE`, `SETE`, or `SETNE`. The names should make it obvious
what they do. The sequence of instructions can be a little obscure,
though. First, we compare RAX and R10; this doesn't modify either of
them, but it sets the flags. Then the `SETcc` operation sets the low 8
bits of RAX to either 1 or 0. But since we can't rely on the top 56
bits all being zero, we do a bitwise and with the constant 1, which
zeros out all of the other bits. The result is that RAX is either 0
or 1. For operations on booleans, you wouldn't need the `and`
instruction, since in this case RAX is known to be either 0 or 1, but
it's convenient to share code between integer and boolean operations
so we keep it.

Comparing floating-point values is harder. The sequence of
instructions looks like this:

    cmpltsd xmm0, xmm1
    movq    rax, xmm0
    and     rax, 1
    
Here, the `CMPccSD` instruction compares two floating-point values and
replaces the destination with either all 1 bits or all 0 bits. We then
move the destination register to `RAX` and and it with 1 to make the
result either 0 or 1. The available comparison operations are
`CMPLTSD`, `CMPLESD`, `CMPEQSD`, and `CMPNEQSD`. You might notice that
there aren't "greater than" operations; to do those, we flip the
arguments to the comparison instruction, and move the result (which is
now in XMM1) to XMM0:

    cmpltsd xmm1, xmm0
    movsd   xmm0, xmm1
    movq    rax, xmm0
    and     rax, 1

The move is unnecessary, but we keep it for the sake of code sharing.

## Constructing and indexing tuples

Constructing tuples is easy, because if all of the tuple parts are on
the stack in the right order, that's identical to having the tuple on
the stack instead. So a tuple constructor doesn't require any
instructions.

Indexing tuples requires determining how many bytes we want to get out
and where they are located in our input. You do this by adding up the
sizes of each field that comes earlier in the tuple. Once you know the
size and the offset, you can copy within the stack.

For example, if you have a `{int, int[], int}` tuple, and you want the
second field (the one of type `int[]`), then the full tuple takes up
32 bytes and you are looking to copy 16 bytes starting 8 bytes in. In
other words, you want to copy 16 bytes from `[rsp + 8]` to `[rsp +
16]`. The corresponding assembly would look like this:

    mov r10, [rsp + 16]
    mov [rsp + 24], r10
    mov r10, [rsp + 8]
    mov [rsp + 16], r10
    add rsp, 16
    
Note that the `add` at the end adjusts the stack---conceptually, we
popped off 32 bytes and pushed 16, leading to a change of 16.

## Constructing and indexing arrays

Constructing arrays requires first determining how many bytes you will
need to allocate on the heap, which you do by multiplying the array
size by the size of an array element. For an array literal, both of
these values are known statically, so you do the multiply at compile
time. Make sure that this multiply does not overflow! Otherwise you'd
end up accessing memory you haven't allocated.

For example, suppose you are compiling the literal `[1, 2, 3]`. This
is three elements of 8 bytes each, so 24 bytes total. So first, we
must allocate 24 bytes:

    mov  rax, 24
    call _jpl_alloc

This puts a heap pointer in RAX. Now, we need to copy 24 bytes from
the stack, at `[rsp]`, into the heap at `[rax]`, which you do using a
sequence of `mov`s. Now we need to put the array data on the stack:

    add  rsp, 24
    push rax
    mov  rax, 3
    push rax

The `add` instruction pops the 24 bytes of arguments off the stack;
then we push the heap pointer on the stack, followed by the array
size, because that is how a JPL array is laid out.

# Local variables

... to be written ...

# Calling functions

A function call has some number of arguments and one output. But how
exactly it is called depends on the details.

Integer and boolean arguments are passed in the registers `rdi`,
`rsi`, `rdx`, `rcx`, `r8`, and `r9`, in that order. Integer and
boolean return values are located in `rax`. So are string arguments,
because string arguments are passed as pointers.

Float arguments are passed in `xmm0`, `xmm1`, `xmm2`, `xmm3`, `xmm4`,
`xmm5`, `xmm6`, and `xmm7`. Float return values are located in `xmm0`.

Struct arguments are passed on the stack, so they do not require any
registers at all. Struct return values, however, mean an extra integer
passed as the first argument, in `rdi` (which contains a pointer to
where that struct must be written).

Calling a function requires setting up each argument; calling the
function; adjusting the alignment; and saving the return value.

Integer and boolean arguments are set with this bit of assembly:

    mov REG, [rsp - XXX]
             
Here `REG` is the destination register and `XXX` is the argument's
position on the stack.

`float` arguments are moved to their destination register like so:

    movsd REG, [rsp - XXX]

String arguments are moved to their destination register like so:

    lea REG, [rel NAME]

Here `NAME` is the name of that string constant. Note that we use
`lea` instead of `mov` since we want to store a pointer in the
register, instead of storing the value at the pointer.

If there are any left-over values, or any struct arguments, you must
move them to be on the stop of the stack.

If the function returns a struct value, it actually takes an extra
first argument. Don't get this wrong. Set that first argument like so
before calling the function:

	lea rdi, [rsp - XXX]

Since it's a first argument, it always takes up the `rdi` register.
This uses the `lea` command instead of the `mov` command to load the
address, not its contents. Note that the stack location needs to be
empty, because it will be overwritten with the function output. It may
not overlap any argument! It's best to reserve space for this
argument before evaluating the function arguments, like so:

    sub rsp, SIZE
    
Once all the arguments, and possibly space for the return value, are
all set up, we need to align the stack. Basically, if the stack is
16-byte aligned, you don't need to do anything, but if it's not, you
must add this before the call:

    sub rsp, 8

Now call the function, using the assembly:

    call _NAME
    
Here, `NAME` is the name of the function. Note the underscore.

After the function returns, undo any alignment change you did:

    add rsp, 8

Finally, adjust the stack to clear all the arguments:

    add rsp, XXX

If the return value was a struct, it'll already be on the stack, so
you don't have to do anything about it. But if the return value was an
integer or boolean, it's in RAX:

    push rax

If it was a float, it's in XMM0:

    add   rsp, 8
    movsd [rsp], xmm0

All of the functions in the JPL runtime use this calling convention.
