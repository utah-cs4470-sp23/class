Assignment 7: Names and Scopes
==============================

For this assignment you will extend your type checker to build symbol
tables and handle names.
 
## The expression subset

In this assignment, you will extend your type checker to handle all of
JPL, including all types of expressions, statements, and commands.
Since you have already built a type checker for (most) expressions in
the [previous assignment](../hw6/README.md), your focus won't be type
checking rules; instead, this assignment will focus on handling names.

Importantly, you must also add support for all of JPL's built-in
functions and values, including:

- `args` and `argnum`
- `sqrt`, `exp`, `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `log`
- `pow` and `atan2`
- `to_int` and `to_float`

Consult the [JPL specification](../spec.md) for the types of these
constructs.

As before, your parser must implement the `-t` and print `Compilation
failed` or `Compilation succeeded` when type checking. We will use
this when testing your compiler. Additionally, for each expression,
your compiler must continue printing the type of that expression. Note
that this type _must be a resolved type_, that is, it must not contain
`VarType`s.

## Representing symbol tables

We recommend creating a new class, `SymbolTable`, which contains two
members: a reference to a parent `SymbolTable` (which will be `null`
for the root symbol table) and a map from strings to a `NameInfo`
class.

Define three subclasses of `NameInfo`: `ValueInfo`, `FunctionInfo`,
and `TypeInfo`. A `ValueInfo` just stores a `ResolvedType` (maybe you
called them `Ty`) for now; later on, it will store more things. A
`FunctionInfo` stores a list of `ResolvedType`s for the argument
types, a `ResolvedType` for the return type, and a child symbol table.
A `TypeInfo` stores the `ResolvedType` the name is defined as.

For now, `NameInfo` will only contain a resolved type, but introducing
this class now will save you some refactoring in future assignments.

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

## Handling variable definitions and uses

We recommend starting with variable definitions and uses, focusing on
the following new JPL constructs:

```
expr : <variable>

cmd : let <lvalue> = <expr>

lvalue : <argument>

argument : <variable>
```

Your `type_of` method, which type-checks expressions, needs an
additional paramter for the current symbol table.

Remove your hard-coded handling of `pict.` when type checking
`VarExpr`s. Instead, look up the variable name in the symbol table,
check that the name maps to `ValueInfo`, and return that value's type.

When handling a `let` command, type check the expression, and then
extract the variable name being defined and add that name to the
current symbol table. Make sure that an exception is raised (either by
`SymbolTable.add` or by the `let` command handler) if the variable
already exists in the symbol table.

Once this works, extend the grammar to handle loop expression:

```
expr : array [ <variable> : <expr> , ... ] <expr>
     | sum [ <variable> : <expr> , ... ] <expr>
```

When type checking `array` and `sum` loops, make sure to type check
the _body_ of the loop using a new symbol table. That new symbol table
should be the child of the current symbol table, with all of the
variables added to it, mapping to integer types. (You must still
enforce all of the other type rules for `array` and `sum`!)

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
    
(Both of these are invalid in JPL.)

## Handling function definitions and uses

Next, we recommend adding support for function definitions and
function calls. This involves a couple of complex pieces.

Start with function _calls_. When type checking a function call, you
must:

- Type check all subexpressions
- Look up the function name
- Check that it is, in fact, a function (it must have a `FunctionInfo`)
- Check that the right number of arguments have been passed
- Check that each subexpressions's type is equal to the corresponding
  argument type
- Return the function's return type

Make sure to include each of these checks! For example, it's easy to
miss the check that you're passing the correct number of arguments; in
JPL that is required.

To test function calls, initialize your global symbol table with all
of the built-in JPL functions like `sin` or `to_int`. Test calls to
these functions.

Now move on to type checking function definitions. The challenge here
is handling bindings.

Create a `ResolvedBinding` class and `ArgumentRBinding` /
`TupleRBinding` subclasses. These are identical to their `Binding`
equivalents, but contains `ResolvedType`s instead of `Type`s. Write a
`resolve_binding` method which converts a `Binding` to a
`ResolvedBinding`.

Implement a `type_binding` method. It should take a `ResolvedBinding`
and return a `ResolvedType` for the type of arguments that can be
passed to that binding.

Implement a `SymbolTable.add_binding` method. It should take a
`ResolvedBinding` and add it to a symbol table. Note that bindings
know their types, so you only need one argument to this method.

Now you can check function definitions. Be careful, because there are
a lot of steps:

- Resolve all bindings by calling `resolve_binding`
- Get types for each argument by calling `type_binding`
- Resolve the return type
- Construct a `FunctionInfo` with those argument & return types
- Add that `FunctionInfo` to the global symbol table
- Create a child symbol table, which will be used for function scope
- Add each binding to the _child_ symbol table using `add_binding`
- Type check each statement

For type checking statements, you will need to write a new `type_stmt`
function. This function takes in a `SymbolTable` and a `ResolvedType`
for the return type, and returns nothing (but updates the
`SymbolTable`). Handling the three types of statements (`let`,
`assert`, and `return`) should be straightforward.

## Resolving types

Finally, we recommend adding type resolution.

First, add handling for the `type` command. A `type` command should
resolve its type argument to a `ResolvedType`, wrap that into a
`TypeType`, and add that to the symbol table.

You likely already have a `resolve_type` method that converts a `Type`
AST node into a `ResolvedType`. Extend that function to take a symbol
table argument. When you attempt to resolve a `VarType`, look up the
variable name in the symbol table; check that the name has a
`TypeType`; and extract the actual type from within the `TypeType`.

Test that `type` commands work properly.

Finally, add support for all other types of commands, including `read`
and `write` commands, `show` commands, `time` commands, and `assert`
commands. All of these should be straightforward, given the helper
methods you've implemented.

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
These tests come in six parts, corresponding to the five directories
of tests.

The directories `vardef` (Part 1), `fancyarg` (Part 2), `fundef` (Part
3), and `typedef` (Part 4) contain both valid and invalid JPL
programs. These are hand-written and intended to guide you through the
recommended parts of this assignment.

The directories `ok-fuzzer` (Part 5) and `fail-fuzzer` (Part 6)
contain auto-generated valid and invalid JPL programs, as in previous
assignments.

You can run these tests on your computer by downloading the
auto-grader and running it like so:

    make -C <auto-grader directory> DIR=<compiler directory> PART=<part>

We recommend trying to get each part working fully before moving on to
the next one.

Depending on how exactly you write your type checker, you might find
that you pass Part 6 very early. This usually happens because you
haven't actually implemented much of JPL and therefore reject all
programs. That means you successfully reject invalid programs, passing
Parts 6. However, don't get too excited: you're rejecting these
programs for the wrong reason, and will probably stop rejecting some
of them once you implement the full JPL type checker.

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
| 20%    | Part 1   |
| 15%    | Part 2   |
| 20%    | Part 3   |
| 15%    | Part 4   |
| 10%    | Part 5   |
| 20%    | Part 6   |

Your solutions will be auto-graded. The auto-grader will use Github
Actions and runs on Ubuntu using the tests described above.
