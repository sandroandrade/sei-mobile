#!/bin/bash

mkdir clang-tidy
cd clang-tidy

qmake -spec linux-clang ..
bear make

/usr/share/clang/run-clang-tidy.py -checks=*,-fuchsia-default-arguments ../*.cpp
