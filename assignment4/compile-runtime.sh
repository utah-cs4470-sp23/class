#!/usr/bin/env bash

set -e
set -u

rm -f runtime.o pngstuff.o runtime.a

clang -O -c runtime.c
clang -O -c pngstuff.c -I/home/regehr/include
ar rcs runtime.a runtime.o pngstuff.o
