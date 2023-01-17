Assignment 2: Writing the Lexer
===============================

Your first assignment is to build a lexical analyzer (a "lexer" or a
"tokenizer") for JPL. Its job is to turn an arbitrary file into one
of:

- A list of tokens
- A lexical error

You will be tested on a collection of lexer test cases created by the
instructors.

# Your Assignment

The lexical syntax of JPL is in the [JPL Specification][lex-spec]. The
full list of tokens you should support is:

[lex-spec]: https://github.com/utah-cs4470-sp23/class/blob/main/spec.md#lexical-syntax

    ARRAY ASSERT BOOL ELSE FALSE FLOAT FN IF IMAGE INT LET PRINT
    READ RETURN SHOW SUM THEN TIME TO TRUE TYPE WRITE
    COLON LCURLY RCURLY LPAREN RPAREN COMMA LSQUARE RSQUARE EQUALS
    STRING INTVAL FLOATVAL VARIABLE OP NEWLINE END_OF_FILE

Note that some tokens, like `ARRAY` or `LCURLY`, correspond to only one
possible string, while other tokens are non-trivial and correspond to
multiple possible strings (`INTVAL`, `OP`). Also note that `OP` is a
single token type covering all of the various arithmetic and boolean
operators, while punctuation characters like `:` get their own token
type. This is done to simplify parsing somewhat.

Your lexer must read in a JPL file and output the sequence of tokens
that it contains. When lexing is successful, a special `END_OF_FILE`
token should be the last element of the list. It does not correspond
to any actual text in the input file, but rather serves as a sentinel
so that your parser will not have to keep checking for walking off the
end of the list of lexemes.

Start to implement the [JPL command line interface][iface],
specifically the "lex-only" mode triggered by the `-l` command line
flag. With this flag, your compiler should print the lexed tokens, one
per line, in a format like this:

    FN 'fn'
    VARIABLE 'inc'
    LPAREN '('
    VARIABLE 'n'
    COLON ':'
    INT 'int'
    RPAREN ')'
    COLON ':'
    INT 'int'
    LCURLY '{'
    NEWLINE
    RETURN 'return'
    INTVAL '1'
    OP '+'
    VARIABLE 'n'
    NEWLINE
    RCURLY '}'
    NEWLINE
    PRINT 'print'
    STRING '"hello!"'
    NEWLINE
    SHOW 'show'
    VARIABLE 'inc'
    LPAREN '('
    INTVAL '33'
    RPAREN ')'
    NEWLINE
    END_OF_FILE
    Compilation successful: lexical analysis complete

Your compiler must also print `Compilation failed` when a lexer error
is encountered. We will use these features when testing your code. Of
course you do not yet need to support the other command line flags.
  
[iface]: https://github.com/utah-cs4470-sp23/class/blob/main/spec.md#jpl-compiler-command-line-interface

Each token prints its name and its contents, except for `NEWLINE` and
`END_OF_FILE` tokens. Since your code will be auto-graded, you must
match this output format exactly.

**Important note:** You should not try to enforce tricky properties,
such as integers or float values being out of range, in your lexer.
These properties are best enforced during parsing.

# Handling Whitespace

Make sure to handle white space correctly:

 - Space characters can separate tokens, but don't generate tokens of
   their own.
 
 - Comments also do not turn into tokens, they are simply eaten by the
   lexer. One-line comments do not include the terminating newline
   character, but multi-line comments can include newlines inside. Be
   particularly careful to avoid emitting multiple consecutive
   `NEWLINE` tokens in the presence of comments in the input.

 - Newlines do turn into tokens, and consecutive newlines in the input
   should be collapsed into a single `NEWLINE` token, even if
   separated by comments or whitespace. Your lexer should never
   produce multiple consecutive `NEWLINE` tokens.
  
 - Line continuations (backslash at the end of a line) likewise does
   not produce a token. The newline that follows it also must not
   produce a token.
   
 - All other whitespace characters are illegal, and you must produce a
   lexer error upon encountering one in a file. As you do your own
   tests, be extra careful that you are saving files with Unix-style
   line endings (LF). Windows-style line endings (CR LF) are invalid
   in JPL.
   
# Implementation Suggestions

The list of tokens should use a suitable list or array data structure
in your compiler implementation language. For example, in C++ it might be:

```
std::vector<token> tokens;
```

where a `token`, as discussed in class, is:

```
struct token {
  tok_type t;
  int start;
  std::string text;
};
```

Note that the `start` field is not required in this assignment, but is
essential to producing good error messages. Since the only user of
your compiler is you, good error messages are an investment worth
making. We recommend saving the name and contents of input file in
memory, from which you can reconstruct the line and column number from
any byte position.

We recommend using regular expressions to define the complex tokens
`INTVAL`, `FLOATVAL`, `VARIABLE`, and `STRING`, as well as whitespace.
C++, Python, and Java all have decent regular expression engines that
support this syntax:

- [C++](http://www.cplusplus.com/reference/regex/ECMAScript/)
- [Java](https://docs.oracle.com/javase/tutorial/essential/regex/)
- [Python](https://docs.python.org/3/library/re.html)

The other token types, especially operators and punctuation, are,
however, probably easier to support using direct string matches. That
makes sure you don't run into tricky bugs related to escaping special
characters in regular expressions.

Rigorously think through both what strings a token should match as
well as which tokens it should *not* match. For example, make sure
`1.0.0` and `.` are not considered valid `FLOATVAL`s! (Though `1.0.0`
_is_ two valid `FLOATVAL`s in a row!) In some cases, you can use order
to help; for example, instead of writing a `VARIABLE` regular
expression that excludes all keywords, it may be easier to match
keywords first, and only match variables if that fails.

# Testing your code

The JPL interpreter in the "[Releases][releases]" supports the `-l`
operation you are being asked to implement. You can run it on any test
file to see the correct lexing of that file:

    ~/Downloads $ ./jplc-macos -l ~/jpl/examples/gradient.jpl
    NEWLINE
    FN 'fn'
    VARIABLE 'gradient'
    LPAREN '('
    VARIABLE 'i'
    COLON ':'
    INT 'int'
    COMMA ','
    VARIABLE 'j'
    COLON ':'
    ...

Naturally, this JPL interpreter is a program and can have bugs. If you
think you've found one, contact the instructors on Discord.

[releases]: https://github.com/utah-cs4470-sp23/class/releases

For larger programs, it can be tedious to compare the list of tokens
by hand. Instead, save each output to a file and use `diff` to
compare:

    diff wrong-output.txt right-output.txt
    
This will print all the lines that differ; you can use various `diff`
flags to get more context for even larger files.

Once things are working, push everything to your repository. Make sure
you can run your compiler like so:

    make run TEST=input.jpl

Here `input.jpl` is a file that we will supply. *Your makefile is
responsible* for passing the `-l` flag to your compiler. Additionally,
the `make compile` command must complete successfully.

You can find the tests and expected outputs [in the auto-grader
repository](https://github.com/utah-cs4470-sp23/grader/tree/main/hw2).
The auto-grader uses these tests in three different ways.

Part 1 asks your compiler to lex each file in `test-lexer1` and
compares your compiler's output to the reference output from our JPL
compiler. There are 179 tests, and your grade on this portion is the
number of these tests that you pass.

Part 2 asks your compiler to lex each file in `test-lexer3` and
verifies that your compiler successfully lexes each file. There are 95
files, and your grade on this portion is the number of these tests
that you pass.

Part 3 asks your compiler to lex each file in `test-lexer3` and
verifies that your compiler issues a lexing error. There are 164
files, and your grade on this portion is the number of these tests
that you pass. A lot of these tests are pretty repetitive, focusing
mostly on invalid characters.

You can run these tests on your computer by downloading the
auto-grader and running it like so:

    make -C <auto-grader directory> DIR=<compiler directory> PART=<part>
    
Generally speaking, Part 1 is the hardest to pass because it requires
you to produce the same exact tokens as the reference lexer. We
recommend focusing on it, and specifically focusing on the first test
that you fail, because in a very loose sense the tests go from easier
to harder.

# Submission and grading

This assignment is due Friday Jan 20.

We are happy to discuss problems and solutions with you on Discord, in
office hours, or by appointment.

Your compiler must be runnable as described in the [Testing your code]
section. If the auto-grader cannot run your code, you will not receive
credit. The auto-grader output is available to you at any time, as
many times as you want. Make use of it.

The rubrik is:

| Weight | Function |
|--------|----------|
| 70%    | Part 1   |
| 15%    | Part 2   |
| 15%    | Part 3   |

Your solutions will be auto-graded. The auto-grader will use Github
Actions and runs on Ubuntu using the tests described above.
