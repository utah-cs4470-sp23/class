# STUDENTS: THIS IS A WORK IN PROGRESS DON'T READ IT YET PLEASE

# Assignment 1: Lexing

Your first assignment is to build a lexical analyzer for JPL. Its job
is to turn an arbitrary file into one of:

- a list of tokens
- a lexer error

The criteria for tokenization are found in the [lexical
syntax](https://github.com/utah-cs4470-sp21/jpl/blob/main/spec.md#lexical-syntax)
part of the JPL specification.

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
better error messages for users of your compiler (such as you).

Lexer requirements:

- When lexing is successful, a special `END_OF_FILE` token should be
  the last element of the list. It does not correspond to any actual
  text in the input file, but rather serves as a sentinel so that your
  parser will not have to keep checking for walking off the end of the
  list of lexemes.

- Every JPL keyword should have its own token type.

- Strings in the input are a token type.

- Other than newlines, white space does not turn into tokens. Rather,
  whitespace is used by the lexer to divide the input stream into
  tokens.

- Occurrences of one or more consecutive newlines in the input should
  be collapsed into a single NEWLINE token. The list of tokens
  produced by your lexer must never contain more than one consecutive
  NEWLINE token.

- Comments do not turn into tokens, they are simply eaten by the
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

## CHECKIN: Due Friday January 29

JPL has both trivial and non-trivial lexemes. A trivial lexeme, such
as `>=`, matches only a single string, whereas a non-trivial lexeme
matches more than one string. For every non-trivial lexeme in JPL,
write a regular expression that precisely matches this lexeme. A
precise match means that your regular expression accepts all valid
instances of the lexeme and rejects all other strings.

Be especially careful that your regular expressions reject illegal
ASCII characters! This syntax `[\x00-\x7F]` can be used to refer to
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
make run input.jpl
```

Here `input.jpl` is a file that we will supply.

The requirement that this works is non-negotiable, so please take it
into account and test it out early, and let us know early if you are
running into any problems so we can see about solving them before the
deadline. (This still has to work if you are using a language other
than Python, Java, or C++.)

```
FIXME instructions for running test scripts
```

