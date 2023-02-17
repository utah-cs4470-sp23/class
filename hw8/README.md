Assignment 8: Functions and Types
=================================

For this assignment you will extend your type checker to support
function and type definitions
 
## Function and type definitions

In this assignment, you will finish your type checker by adding
support for function and type definitions. Specifically, you will add 
support for the following syntactic constructs:

```
cmd  : type <variable> = <type>
     | fn <variable> ( <binding> , ... ) : <type> { ;
           <stmt> ; ... ;
       }

stmt : let <lvalue> = <expr>
     | assert <expr> , <string>
     | return <expr>

binding : <argument> : <type>
        | { <binding> , ... }

expr : <variable> ( <expr> , ... )
```

You must also add support for all of JPL's built-in functions:

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

## Function and type information

Extend your symbol table to store function and type information by
adding two new subclasses of `NameInfo`: `FunctionInfo`, and
`TypeInfo`.

A `FunctionInfo` stores a list of `ResolvedType`s for the argument
types, a `ResolvedType` for the return type, and a child symbol table.
That child symbol table is the symbol table used for checking the
function body, and will be useful to us when writing the compiler
back-end.

A `TypeInfo` stores the `ResolvedType` the name is defined as.

Now, add handling for the `type` command. A `type` command should
resolve its type argument to a `ResolvedType` and add that to the
symbol table as a `TypeInfo`.

You likely already have a `resolve_type` method that converts a `Type`
AST node into a `ResolvedType`. Extend that function to take a symbol
table argument. When you attempt to resolve a `VarType`, look up the
variable name in the symbol table; check that the name has a
`TypeType`; and extract the actual type from within the `TypeType`.

Test that `type` commands work properly. Now that you've added support
for type definitions, be very careful with the difference between
`Type`s, which are AST nodes, and `ResolvedType`s, which are the
actual, concrete types of values. The rest of your compiler should
only use `ResolvedType`s; all `Type` AST nodes should not be used once
your type checker is done.

## Handling function calls

Next, add support for function _calls_. When type checking a function
call, you must:

- Type check all subexpressions (the function arguments)
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

## Handling function definitions

Now move on to type checking function definitions. For now, assume all
bindings are the simple case:

```
binding : <argument> : <type>
```

To type-check a function definition, you need to:

- Extract the `Argument` and `Type` from each parameter
- Resolve the argument and return types
- Create a child symbol table, which will be used for function scope
- Construct a `FunctionInfo` with those argument & return types, and
  child symbol table
- Add that `FunctionInfo` to the global symbol table
- Add each binding to the _child_ symbol table using `add_binding`
- Type check each statement inside the function

For type checking statements, you will need to write a new `type_stmt`
function. The actual type checking should be pretty straight-forward,
since you've already implemented type checking for `let` and `assert`
commands, which work the same as `let` and `assert` statements.

However, the `return` statement needs some special care, because for a
`return` statement to be valid, it must return a value of the same
type as the function's declared return type. Therefore, add an
argument to `type_stmt` for the function's declared return type,
and use that when type checking `return` statments.

## Handling complex bindings

Finally, extend your handling of function arguments to handle tuple
binding:

```
binding : { <binding> , ... }
```

To keep this simple, write a function that converts a `Binding` into a
pair of `LValue` and `Type`. This is straightforward for both types of
bindings.

Now, modify your handling of function parameters. For each function
parameter, you will need to:

- Convert the `Binding` into an `LValue` and a `Type`
- Resolve the `Type`
- Add the `LValue` to the child symbol table

Make sure to test your code with complicated recursive bindings, such
as the following:

```
fn foo({{x : int}, {}, {y : int, z : {int, int}}}, {}, w : int) : int {
    return x + w
}
```

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
