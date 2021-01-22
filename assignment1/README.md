# Assignment 1: Lexing

Your first assignment is to build a lexical analyzer (a "lexer" or a "tokenizer") for JPL. Its job
is to turn an arbitrary file into one of:

- A list of tokens
- A lexical error

The criteria for tokenization are found in the [lexical
syntax](https://github.com/utah-cs4470-sp21/jpl/blob/main/spec.md#lexical-syntax)
part of the JPL specification. The full list of tokens you should support is: 
NEWLINE, INTVAL, FLOATVAL, VAR, ARRAY, SUM, IF, THEN,
ELSE, LET, RETURN, ASSERT, READ, WRITE, TO, PRINT, SHOW,
TIME, FN, FLOAT3, FLOAT4, COLON, LCURLY, RCURLY, LPAREN,
RPAREN, STRING, COMMA, LSQUARE, RSQUARE, EQUALS, BINOP,
BOOLNOT, ERROR, ATTRIBUTE, END_OF_FILE.

Note that some tokens are trivial---they correspond to only one possible
string (ATTRIBUTE, LCURLY)---while other tokens are non-trivial and
correspond to multiple possible strings (INTVAL, BINOP).

The list of tokens should use a suitable list or array data structure
in your compiler implementation language. For example, in C++ it might be:

```
std::vector<lexeme> tokens;
```

where a lexeme is:

```
struct lexeme {
  tok t;
  int line;
  std::string text;
};
```

where `tok` is an enumerated type, `line` is the line number of the
input file where the lexeme was found, and `text` is the lexeme
itself. Note that the `line` field is not required in your lexer, but
retaining this kind of information will be very helpful in producing
better error messages for users of your compiler (mainly you). You
might also want to record the character position within the line
where each token starts, but again this is not required.

Lexer requirements:

- When lexing is successful, a special `END_OF_FILE` token should be
  the last element of the list. It does not correspond to any actual
  text in the input file, but rather serves as a sentinel so that your
  parser will not have to keep checking for walking off the end of the
  list of lexemes.

- Other than newlines, white space does not turn into tokens. Rather,
  whitespace is used by the lexer to divide the input stream into
  tokens.

- Occurrences of one or more consecutive newlines in the input should
  be collapsed into a single NEWLINE token. The list of tokens
  produced by your lexer must never contain more than one consecutive
  NEWLINE token.
  
- Line continuations (backslash at the end of a line) likewise do not
  correspond to tokens. The lexer should just take them into account
  when handling whitespace.

- Comments also do not turn into tokens, they are simply eaten by the
  lexer. Be particularly careful to avoid emitting multiple
  consecutive NEWLINE tokens in the presence of comments in the input.

- You must start to implement the [JPL command line
  interface](https://github.com/utah-cs4470-sp21/jpl/blob/main/spec.md#jpl-compiler-command-line-interface).
  In particular, your implementation for this assignment should
  support the `-l` flag and it must print (to STDOUT) `Compilation
  successful` when lexing is successful and `Compilation failed` when
  a lexer error is encountered. We will use these features when
  testing your code. Of course you do not yet need to support the
  other command line flags.

- The "lex-only" mode of your compiler that is triggered by the `-l`
  command line flag should dump tokens, one per line, in a format like
  the one shown here. Note that you must not print the content of NEWLINE
  tokens, but must print the content for all other tokens types. We are
  providing you with a test script that checks your output against ours,
  so it is important that you match this output format exactly.

```
regehr@home:~/compiler-class/jdr/build$ cat tiny.jpl 
fn inc(n : int) : int {
  return 1 + n
}

print "hello!"
show inc(33)
regehr@home:~/compiler-class/jdr/build$ ./jplc -l tiny.jpl 
FN 'fn'
VARIABLE 'inc'
LPAREN '('
VARIABLE 'n'
COLON ':'
VARIABLE 'int'
RPAREN ')'
COLON ':'
VARIABLE 'int'
LCURLY '{'
NEWLINE
RETURN 'return'
INTVAL '1'
BINOP '+'
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
Compilation succeeded
regehr@home:~/compiler-class/jdr/build$ 
```

## CHECKIN: Due Friday January 29

JPL has both trivial and non-trivial lexemes. A trivial lexeme, such
as `>=`, matches only a single string, whereas a non-trivial lexeme
matches more than one string. List all non-trivial lexemes.

For every non-trivial lexeme in JPL, write a regular expression
that precisely matches this lexeme. A precise match means that your
regular expression accepts all valid instances of the lexeme and
rejects all other strings.

Write a regular expression that matches valid JPL whitespace. Recall
that whitespace is not a token type---it separates tokens and is
consumed by the lexer.

Write a regular expression that matches comments. Recall that,
like whitespace, comments aren't a token type.

Be especially careful that your regular expressions reject illegal
ASCII characters! The syntax `[\x00-\x7F]` can be used to refer to
specific ASCII values.

Your regular expressions should follow the POSIX extended regular
expression format as described
(here)[https://en.wikipedia.org/wiki/Regular_expression].

Place these regular expressions into an ASCII text file called
`assignment1.txt` which must live in the root directory of your repo.

## HANDIN: Due Friday February 5

Submit a lexer for JPL. The code must be in your repo, and we must be
able to run it on a CADE lab Linux machine by going to the top-level
directory of your repo and typing this:

```
make run TEST=input.jpl
```

Here `input.jpl` is a file that we will supply.

The requirement that this works is non-negotiable, so please take it
into account and test it out early, and let us know early if you are
running into any problems so we can see about solving them before the
deadline. (This still has to work if you are using a language other
than Python, Java, or C++.)

We are providing two scripts that you can use to test your lexer is
working properly. These are the same scripts that we will use to grade
your lexer. (In future assignments, we might do grading using test
cases that we have not given you, but we are not doing that yet.)

The first script, `test-lexer1` compares the output of your compiler,
in lexer mode, against a reference lexer. It complains if your output
does not exactly match the reference output. It uses the `-l` flag
mentioned in the JPL specification. Run it like this, but instead of
`../jdr/build/jplc` you should specify the location of your compiler
executable:

```
Johns-MacBook-Pro:tests johnregehr$ ./test-lexer1 ../jdr/build/jplc 
/Users/johnregehr/compiler-class/tests/lexer-tests1
/Users/johnregehr/compiler-class/tests/lexer-tests1/000.jpl : pass
/Users/johnregehr/compiler-class/tests/lexer-tests1/001.jpl : pass
/Users/johnregehr/compiler-class/tests/lexer-tests1/002.jpl : pass
/Users/johnregehr/compiler-class/tests/lexer-tests1/003.jpl : pass
/Users/johnregehr/compiler-class/tests/lexer-tests1/004.jpl : *** /Users/johnregehr/compiler-class/tests/lexer-tests1/004.jpl.my-output	2021-01-22 11:50:39.000000000 -0700
--- /Users/johnregehr/compiler-class/tests/lexer-tests1/004.jpl.output	2021-01-22 11:43:08.000000000 -0700
***************
*** 2,8 ****
  FN 'fn'
  VARIABLE 'a'
  LPAREN '('
! VARIABLE 'b '
  LSQUARE '['
  VARIABLE 'c'
  RSQUARE ']'
--- 2,8 ----
  FN 'fn'
  VARIABLE 'a'
  LPAREN '('
! VARIABLE 'b'
  LSQUARE '['
  VARIABLE 'c'
  RSQUARE ']'
Johns-MacBook-Pro:tests johnregehr$ 
```

In this example run, the output of my lexer matched the reference
output for `000.jpl` through `003.jpl` but then did not match for
`004.jpl`. The difference is shown with the correct output first and
your output second.  In this case the bug is that my lexer
accidentally captured an extra space character after the text for the
variable `b`. You should fix any bugs found by this lexer test before
this assignment is due. The lexer inputs and expected outputs are all
there for you to look at, the test script simply provides convenient
automation.

Run the second test script, `test-lexer2`, the same way. This one does
not look at the actual lexer output, but rather simply checks if
lexing succeeds (because the input can be lexed) or fails (because the
input does not meet the requirements for lexing that are described in
the JPL specification).

