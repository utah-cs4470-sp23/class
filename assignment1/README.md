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
in your compiler implementation language. For example in C++ it might be:

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


