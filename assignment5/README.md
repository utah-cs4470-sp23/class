# Assignment 5: Expanding the JPL Subset

Your fifth assignment is to expand your compiler front end (lexer,
parser, and type checker) to handle a much larger subset of the full
JPL language. In the interests of time, we are not _quite_ asking you
to handle the full language; instead, we are dropping a couple of
features:

- All uses of tuples, including in the type system
- As part of that, `read image` and `write image` will operate on
  monochrome (gray) images
- All of the complex binding forms. Instead, there will be a `dim`
  built-in function for getting the dimension of an array.

The full syntax for this subset is given below.

Your job for this assignment is to extend your parser and type checker
to handle this larger subset of JPL.

Note that we're not asking you to extend flattening and code
generation---there isn't enough time, and ultimately that would mostly
be more of the same code generation that you've already done.

Grammar
-------

The full grammar that you are parsing has four syntax classes: types,
expressions, statements, and commands. All of them have the same
meaning as in the [full language](../spec.md), except that `read
image` and `write image` operate on monochrome images of type
`float[,]` instead of four-channel images of type `float4[,]`.

```
type : int
     | bool
     | float
     | <type> [ , ... ]
```

The type system adds multi-dimensional arrays to the types already
handled by your language. The `pict` type that you implemented in
[Assignment 4](../assignment4/README.md) should be removed; images
should now have type `float[,]`.

Expressions include _most_ of the expressions offered by the full
language:

```
expr : <integer>
     | <float>
     | true
     | false
     | <variable>

     | ( <expr> )
     | <expr> + <expr>
     | <expr> - <expr>
     | <expr> * <expr>
     | <expr> / <expr>
     | <expr> % <expr>
     | - <expr>
     | <expr> < <expr>
     | <expr> > <expr>
     | <expr> == <expr>
     | <expr> != <expr>
     | <expr> <= <expr>
     | <expr> >= <expr>
     | <expr> && <expr>
     | <expr> || <expr>
     | ! <expr>

     | array [ <variable> : <expr> , ... ] <expr>
     | sum [ <variable> : <expr> , ... ] <expr>
     | <expr> [ <expr> , ... ]

     | if <expr> then <expr> else <expr>
     | <variable> ( <expr> , ... )
```

Statements and commands are identical to the subset you've already
implemented, again noting that `read image` and `write image` only
handle monochrome images. However, in this subset we are also adding
function definitions:

```
cmd  : fn <variable> ( <binding> , ... ) : <type> { ;
           <stmt> ; ... ;
       }
    
binding : <variable> : <type>
```

We decided (again in the interest of time) not to add the complex
binding forms, so instead we are adding a builtin, `dim`:

```
expr : dim(<expr>, <expr>)
```

The first argument to `dim` must be an array, of an arbitrary rank.
The second must be an integer. The result is an integer, giving the
length of the array in the given dimention. For example,

    dim(array[i : N] f(i), 0)

must return `N`, because the first argument is a rank-1 array whose
first dimension has length `N`.

The hardest part of this assignment will be correctly parsing this
much larger class of expressions, and in particular handling
precedence for mathematical operators.

It will also be challenging to correctly type-check `array` and `sum`
expressions.

Precedence
----------

Study the precedence rules in the [JPL specification](../spec.md).

These rules explain how some *ambiguous expressions* need to be
parsed. It's easiest to explain this on a smaller and simpler language
than JPL. Consider a simplified language with just numbers, addition,
and multiplication:

```
expr : <integer>
     | <expr> + <expr>
     | <expr> * <expr>
```

As written, `1 + 2 * 3` can be parsed both as `(1 + 2) * 3` or as `1 +
(2 * 3)`. Since we want the second parse tree and not the first, we
need to modify the grammar to rule the second one out.

Consider this expanded grammar:

```
expr1 : <expr1> + <expr1>
      | <expr2>

expr2 : <expr2> * <expr2>
      | <integer>
```

Instead of a single `<expr>` syntax class, there is now an `<expr1>`
and an `<expr2>` syntax class. Moreover, every `<expr2>` is an
`<expr1>` (via the second rule) but the reverse isn't true. For
example, `1 + 2` is a valid `<expr1>`, but it isn't a valid `<expr2>`.
So consider the two possible parse trees of `1 + 2 * 3`:

- In `1 + (2 * 3)`, `2` and `3` are `<expr2>`s via the fourth rule,
  which means that `2 * 3` is a valid `<expr2>` as well, which makes
  it a valid `<expr1>`. And `1` is a valid `<expr2>` which makes it
  also a valid `<expr1>`. So `1 + 2 * 3` is a valid `<expr1>` as well.
  
- In `(1 + 2) * 3`, `1 + 2` is a valid `<expr1>`, but it is not a
  valid `<expr2>`. That means it can't be on the left hand side of a
  multiplication, so this parse tree isn't valid.

You can do the same trick with larger grammars, like the full JPL grammar.

## CHECKIN Due March 26

TODO: John please expand this part

- Define AST classes for everything
- Write an expanded grammar with precedence
- Write the signature for the type checking function
- Write the type checking function for `array` expressions

Please also produce an _expanded grammar_ for the subset of JPL
defined here, which enforces precedence. Specifically, this grammar
should be similar to the grammar given above for `<expr>`, except that
instead of one `<expr>` syntax class it should have syntax classes
`<expr1>`, `<expr2>`, `<expr3>`, and so on. An expression where
precedence is important, such as `1 + 2 * 3`, must have exactly one
parse tree according to this grammar.

## HANDIN Due April 2

Support the `-p` and `-t` flags for the subset defined here.

Test parsing with this special tester: TODO

Test precedence with this special tester: TODO

Test types with this special tester: TODO
