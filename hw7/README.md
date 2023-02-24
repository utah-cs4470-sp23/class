Assignment 7: Names and Scopes
==============================

For this assignment you will extend your type checker to build symbol
tables and handle variable definitions.
 
## The command subset

In this assignment, you will extend your type checker to handle most
of JPL---all of the types of expressions and commands, except for type
and function definitions. Since you have already built a type checker
for (most) expressions in the [previous assignment](../hw6/README.md),
this assignment will focus on handling names.

Specifically, you add support for the following subset of JPL:

```
expr : array [ <variable> : <expr> , ... ] <expr>
     | sum [ <variable> : <expr> , ... ] <expr>

cmd  : read image <string> to <argument>
     | write image <expr> to <string>
     | let <lvalue> = <expr>
     | assert <expr> , <string>
     | print <string>
     | time <cmd>

argument : <variable> [ <variable> , ... ]

lvalue : { <lvalue> , ... }
```

Additionally, you should remove the hard-coded type for `pict.` and
replace it with a proper symbol table to resolve the types of
variables.

As before, your parser must implement the `-t` and print `Compilation
failed` or `Compilation succeeded` when type checking. We will use
this when testing your compiler. Additionally, for each expression,
your compiler must continue printing the type of that expression.

## Representing symbol tables

We recommend creating a new class, `SymbolTable`, which contains two
members: a reference to a parent `SymbolTable` (which will be `null`
for the root symbol table) and a map from strings to a `NameInfo`
class.

For now, you'll only need one subclass of `NameInfo`: `VariableInfo`,
which will just store a `ResolvedType` for the type of the variable.
(In Assignment 8, you will add handling for function and type
definitions, and end up with more subclasses of `NameInfo`.)

We recommend defining three helper functions on `SymbolTable`s: `add`,
`get`, and `has`. The behavior should be clear from the name, noting
only that `add` adds to the inner-most `SymbolTable`, but `get` and
`has` check all the symbol tables. The `add` helper should throw a
`TypeError` if the symbol table already `has` that name. We also
recommend adding an easy way to construct a new child of a given
`SymbolTable`.

Your top-level type check function (which before starting this
assignment just looped over a bunch of `ShowCmd`s) should now create
and the global symbol table at the start and return the global symbol
table at the end. The rest of your compiler will need this global
symbol table.

## Adding commands

To begin, add type checking for all of the commands that don't bind
new variables:

```
cmd  : write image <expr> to <string>
     | assert <expr> , <string>
     | print <string>
     | time <cmd>
```

To do so, we recommend defining a `type_cmd` function, which takes as
input a `Cmd` AST node and a symbol table and type checks the given
command. Note that commands don't return values (unlike expressions)
so the `type_cmd` function does not need to return anything. However,
it does need to typecheck all subexpressions and check some type
rules. For example, in an `assert` expression, you must check that the
asserted expression evaluates to a boolean.

Additionally, set up your initial global symbol table to give the
correct types for the `args` and `argnum` built-in variables. Consult
the [JPL specification](../spec.md) for their types.

## Handling variable definitions and uses

We recommend starting with variable definitions and uses, focusing on
the following new JPL constructs:

```
expr : <variable>

cmd : let <lvalue> = <expr>
    | read image <string> to <argument>

lvalue : <argument>

argument : <variable>
```

Your `type_of` method, which type-checks expressions, needs an
additional paramter for the current symbol table.

Remove your hard-coded handling of `pict.` when type checking
`VarExpr`s. Instead, look up the variable name in the symbol table,
check that the name maps to `VariableInfo`, and return that value's
type.

When handling a `let` command, type check the expression, and then
extract the variable name being defined and add that name to the
current symbol table. Make sure that an exception is raised (either by
`SymbolTable.add` or by the `let` command handler) if the variable
already exists in the symbol table.

When handling a `read` command, the value being read always has the
same type, `{float,float,float,float}[,]`.

## Array and sum expressions

Once this works, extend the grammar to handle loop expression:

```
expr : array [ <variable> : <expr> , ... ] <expr>
     | sum [ <variable> : <expr> , ... ] <expr>
```

When type checking `array` and `sum` loops, make sure to type check
the _body_ of the loop using a new symbol table. That new symbol table
should be the child of the current symbol table, with all of the
variables added to it, mapping to integer types.

You must enforce all of the other type rules for `array` and `sum`.
For example, you must ensure that all the loop bounds evaluate to
integers, that the body of a `sum` expression has a numeric type, and
you must return an array type of the proper size from an `array`
expression.

If you do it right, after you add type checking for `array` and `sum`,
you won't need to modify your `VarExpr` handling at all.

## Handling complex arguments

Next, we recommend adding support for complex arguments and L-values:

```
argument : <variable> [ <variable> , ... ]

lvalue : { <lvalue> , ... }
```

This makes your handling of `let` more complex, because it is now
possible to bind multiple variables at the same time, as in:

    let { a[W], b } = { [1, 2, 3], 4 }
    
(This expression binds `a` to the array `[1, 2, 3]`, `W` to that
array's length `3`, and `b` to the value `4`. If you need to review
how binding works in JPL, remember to consult the
[specification](../spec.md).)

We recommend adding helper methods `add_argument` and `add_lvalue` to
the `SymbolTable`. These helper methods take an `Argument`/`LValue`
and a `ResolvedType` and update the `SymbolTable` accordingly. Note
that `LValue`s are recursive, so `add_lvalue` will be too. These
methods may fail with a `TypeError`, for example if you try to add a
`TupleLValue` with a non-tuple type.

Make sure you test failure cases, like using an `ArrayArgument` with a
non-array value or a `TupleLValue` with a non-tuple value.
Additionally, test failure cases like using the same variable twice in
the same argument or lvalue, as in:

    let a[a] = [1]
    let {a, a} = {1, 2}
    
Both of these assignments are invalid in JPL.

# Testing your code

Just like in the last homework, the JPL interpreter in the
"[Releases][releases]" supports the `-t` operation you are being asked
to implement. You can run it on any test file to see the correct
parsing of that file:

    ~/Downloads $ ./jplc-macos -p ~/jpl/examples/cat.jpl
    (ShowCmd (ArrayLoopExpr (ArrayType (IntType) 1)
               x (IntExpr (IntType) 1)
               (BinopExpr (IntType) (IntExpr (IntType) 1)
                          +
                          (VarExpr (IntType) x))))
    Compilation succeeded: parsing complete

Naturally, this JPL interpreter is a program and can have bugs. If you
think you've found one, contact the instructors on Discord.

[releases]: https://github.com/utah-cs4470-sp23/class/releases

Pretty-printing and comparing these S-expression outputs works as in
[prior assignments](../hw5/README.md).

You can find the tests and expected outputs [in the auto-grader
repository](https://github.com/utah-cs4470-sp23/grader/tree/main/hw6).

The directories `ok` (Part 1) and `fail` (Part 2) contain valid and
invalid hand-written JPL programs to guide you through this
assignment.

The `ok-fuzzer` (Part 3), and `fail-fuzzer` (Part 4) directories, on
the other hand, contain valid and invalid auto-generated JPL programs.

You can run these tests on your computer by downloading the
auto-grader and running it like so:

    make -C <auto-grader directory> DIR=<compiler directory> PART=<part>

We recommend trying to get each part working fully before moving on to
the next one.

Depending on how exactly you write your type checker, you might find
that you pass Parts 2 and 4 very early. This usually happens because
you haven't actually implemented much of JPL and therefore reject all
of those programs. However, don't get too excited: you're rejecting
these programs for the wrong reason, and will probably stop rejecting
some of them once you implement the full JPL type checker.

# Submission and grading

This assignment is due Friday Feb 24.

We are happy to discuss problems and solutions with you on Discord, in
office hours, or by appointment.

Your compiler must be runnable as described in the [Testing your
code][Testing your code] section. If the auto-grader cannot run your
code, you will not receive credit. The auto-grader output is available
to you at any time, as many times as you want. Make use of it.

The rubrik is:

| Weight | Function |
|--------|----------|
| 30%    | Part 1   |
| 30%    | Part 2   |
| 25%    | Part 3   |
| 15%    | Part 4   |

Your solutions will be auto-graded. The auto-grader will use Github
Actions and runs on Ubuntu using the tests described above.
