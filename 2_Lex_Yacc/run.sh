#!/bin/sh
echo "LEX:"
lex Cmm.l
echo "YACC:"
yacc -t Cmm.y
echo "GCC:"
gcc -o Cmm y.tab.c
