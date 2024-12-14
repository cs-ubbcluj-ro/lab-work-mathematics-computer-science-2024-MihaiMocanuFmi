%{

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

%}


%%

"//".*      {/*skip comment line*/}

"#include"  {return INCLUDE;}

"=="        {return EQUAL_EQUAL;}
"!="        {return EXCLAMATION_EQUAL;}
"<="        {return LESS_EQUAL;}
">="        {return GREATER_EQUAL;}
"<"         {return LESS;}
">"         {return GREATER;}

"+="        {return PLUS_EQUAL;}
"-="        {return MINUS_EQUAL;}
"*="        {return STAR_EQUAL;}
"/="        {return SLASH_EQUAL;}
"="         {return EQUAL;}

"++"        {return PLUS_PLUS;}
"--"        {return MINUS_MINUS;}

"||"        {return BAR_BAR;}
"&&"        {return AMPERSANT_AMPERSANT;}
"^"         {return ARROW;}

"+"         {return PLUS;}
"-"         {return MINUS;}
"*"         {return STAR;}
"/"         {return SLASH;}

"!"         {return EXCLAMATION;}

"void"      {return VOID_K;}
"char"      {return CHAR_K;}
"int"       {return INT_K;}
"double"    {return DOUBLE_K;}
"const"     {return CONST_K;}
"if"        {return IF_K;}
"else"      {return ELSE_K;}
"while"     {return WHILE_K;}
"return"    {return RETURN_K;}
"struct"    {return STRUCT_K;}
"main"      {return MAIN_K;}
"read"      {return READ_K;}
"write"     {return WRITE_K;}

[_a-zA-Z][_a-zA-Z0-9]*              {return IDENTIFIER;}
[+-]?(([1-9][0-9]+)|[0-9])\.[0-9]+  {return REAL;}
[+-]?(([1-9][0-9]+)|[0-9])          {return INTEGER;}

'.'         {return CHAR_LIT;}
\".*\"      {return STR_LIT;}

"{"         {return BRACKET_LEFT;}
"}"         {return BRACKET_RIGHT;}
"("         {return PARANTH_LEFT;}
")"         {return PARANTH_RIGHT;}
"["         {return SQ_BRACKET_LEFT;}
"]"         {return SQ_BRACKET_RIGHT;}
","         {return COMMA;}
";"         {return SEMICOLON;}
"."         {return DOT;}

[ \t]       {/*return WS;*/}
[\r]        {}
[\n]        {}
.           {}

%%

int yywrap(void) {
    return 1;
}
