%{
#include <stdio.h>
#define YYSTYPE double

int yylex(void);
void yyerror(const char *s);

void trace(const char* rule_name, unsigned id)
{
    static unsigned count = 0;
    printf("%u:\t %s -> %u\n", count++, rule_name, id);
}

int yydebug = 0;

%}

%debug

%token INCLUDE

%token EQUAL_EQUAL
%token EXCLAMATION_EQUAL
%token LESS_EQUAL
%token GREATER_EQUAL
%token LESS
%token GREATER

%token PLUS_EQUAL
%token MINUS_EQUAL
%token STAR_EQUAL
%token SLASH_EQUAL
%token EQUAL

%token PLUS_PLUS
%token MINUS_MINUS

%token BAR_BAR
%token AMPERSANT_AMPERSANT
%token ARROW

%token PLUS
%token MINUS
%token STAR
%token SLASH

%token EXCLAMATION

%token VOID_K
%token CHAR_K
%token INT_K
%token DOUBLE_K
%token CONST_K
%token IF_K
%token ELSE_K
%token WHILE_K
%token RETURN_K
%token STRUCT_K
%token MAIN_K
%token READ_K
%token WRITE_K

%token IDENTIFIER
%token REAL
%token INTEGER

%token CHAR_LIT
%token STR_LIT

%token BRACKET_LEFT
%token BRACKET_RIGHT
%token PARANTH_LEFT
%token PARANTH_RIGHT
%token SQ_BRACKET_LEFT
%token SQ_BRACKET_RIGHT
%token COMMA
%token SEMICOLON
%token DOT

%%

program: /*empty*/ {trace("program", 1);}
       | main_fct program {trace("program", 2);}
       | function_declaration program {trace("program", 3);}
       | function_definition program {trace("program", 4);}
       | struct_definition program {trace("program", 5);}
       ;

main_fct: INT_K MAIN_K PARANTH_LEFT PARANTH_RIGHT BRACKET_LEFT function_subprogram BRACKET_RIGHT {trace("main_fct", 1);}
        ;

function_subprogram: subprogram return {trace("function_subprogram", 1);}
                   ;

subprogram: variable_declaration SEMICOLON subprogram{trace("subprogram", 1);}  //int a, b = 3;
          | variable_assigment SEMICOLON subprogram {trace("subprogram", 2);}    // a = 3;
          | code_structure subprogram {trace("subprogram", 3);}        // if(...) ... while()
          | function_call SEMICOLON subprogram {trace("subprogram", 4);}
          | /*empty*/ {trace("subprogram", 5);}

variable_declaration: type IDENTIFIER {trace("variable_declaration", 1);}
                    | type_arr IDENTIFIER {trace("variable_declaration", 2);}
                    | type variable_assigment_init {trace("variable_declaration", 3);}
                    | type_arr variable_arr_assigment_init {trace("variable_declaration", 4);}
                    ;

type: CHAR_K {trace("type", 1);}
    | INT_K {trace("type", 2);}
    | DOUBLE_K {trace("type", 3);}
    | CONST_K type {trace("type", 4);}
    | type CONST_K {trace("type", 5);}
    | STRUCT_K IDENTIFIER {trace("type", 6);}
    | type STAR {trace("type", 7);}
    ;

type_arr: type_arr SQ_BRACKET_LEFT SQ_BRACKET_RIGHT {trace("type_arr", 1);}
        | type_arr SQ_BRACKET_LEFT value SQ_BRACKET_RIGHT {trace("type_arr", 2);}
        | type SQ_BRACKET_LEFT SQ_BRACKET_RIGHT {trace("type_arr", 4);}         // got rid of 1 shift/reduce
        | type SQ_BRACKET_LEFT value SQ_BRACKET_RIGHT {trace("type_arr", 5);}
        ;

variable_assigment_init: IDENTIFIER EQUAL value {trace("variable_assigment_init", 1);}
                       ;

variable_assigment: l_value binary_assigment_operators value {trace("variable_assigment", 1);}
                  | l_value unary_assigment_operators {trace("variable_assigment", 2);}
                  ;

variable_arr_assigment_init: l_value EQUAL value_bracket_list {trace("variable_arr_assigment_init", 1);}
                       ;

value_bracket_list: BRACKET_LEFT value_bracket_list__inner BRACKET_RIGHT {trace("value_bracket_list", 1);}
                  | BRACKET_LEFT BRACKET_RIGHT {trace("value_bracket_list", 2);}
                  ;

value_bracket_list__inner: value COMMA value_bracket_list__inner {trace("value_bracket_list__inner", 1);}
                         | value {trace("value_bracket_list__inner", 1);}
                         ;

value: single_value {trace("value", 1);}
     | value_expr {trace("value", 2);}
     ;

single_value: l_value {trace("single_value", 1);}
            | r_value {trace("single_value", 2);}
            ;

l_value: IDENTIFIER {trace("l_value", 1);}
       | l_value DOT l_value {trace("l_value", 2);}
       | l_value SQ_BRACKET_LEFT value SQ_BRACKET_RIGHT {trace("l_value", 3);}
       ;

r_value: CHAR_LIT {trace("r_value", 1);}
       | STR_LIT {trace("r_value", 2);}
       | INTEGER {trace("r_value", 3);}
       | REAL {trace("r_value", 4);}
       | function_call {trace("r_value", 5);}
       | value_bracket_list {trace("r_value", 6);}
       ;

value_expr: single_value binary_arithmetical_operators value_expr {trace("value_expr", 1);}
          | single_value binary_arithmetical_operators single_value {trace("value_expr", 2);}
          | single_value unary_assigment_operators {trace("value_expr", 3);};
          | unary_assigment_operators single_value {trace("value_expr", 3);};
          ;

// Reduce/Reduce conflicts...
// value_expr: value_expr__term value_expr__list_cont__opt {trace("value_expr", 2);}
//           ;
//
// value_expr__list_cont__opt: /* empty */ {trace("value_expr__list_cont__opt", 2);}
//                           | value_expr__list_cont
//                           ;
//
// value_expr__list_cont : value_expr__term {trace("value_expr__list_cont", 2);}
//                       | STAR value_expr__list_cont {trace("value_expr__list_cont", 2);}
//                       | MINUS value_expr__list_cont {trace("value_expr__list_cont", 2);}
//                       ;
//
// value_expr__term: value_expr__factor value_expr__term__list_cont__opt {trace("value_expr__term", 2);}
//                 ;
//
// value_expr__term__list_cont__opt: /* empty */ {trace("value_expr__term__list_cont__opt", 2);}
//                                 | value_expr__term__list_cont {trace("value_expr__term__list_cont__opt", 2);}
//                                 ;
//
// value_expr__term__list_cont: STAR value_expr__factor {trace("value_expr__term__list_cont", 2);}
//                            | SLASH value_expr__factor {trace("value_expr__term__list_cont", 2);}
//                            ;
//
// value_expr__factor: PARANTH_LEFT value_expr PARANTH_RIGHT {trace("value_expr__factor", 2);}
//                   | value {trace("value_expr__factor", 2);}
//                   ;

code_structure: while_structure {trace("code_structure", 1);}
              | if_structure {trace("code_structure", 2);}
              ;

while_structure: WHILE_K PARANTH_LEFT boolean_expr PARANTH_RIGHT BRACKET_LEFT subprogram BRACKET_RIGHT {trace("while_structure", 1);}
               ;

boolean_expr: boolean_expr__term binary_logical_operators boolean_expr {trace("value_expr", 1);}
            | boolean_expr__term  {trace("value_expr", 2);}
            ;

boolean_expr__term: single_value binary_relational_operators single_value
                  ;
if_structure: IF_K PARANTH_LEFT boolean_expr PARANTH_RIGHT BRACKET_LEFT subprogram BRACKET_RIGHT {trace("if_structure", 1);}
            | IF_K PARANTH_LEFT boolean_expr PARANTH_RIGHT BRACKET_LEFT subprogram BRACKET_RIGHT ELSE_K BRACKET_LEFT subprogram BRACKET_RIGHT {trace("if_structure", 2);}
            | IF_K PARANTH_LEFT boolean_expr PARANTH_RIGHT BRACKET_LEFT subprogram BRACKET_RIGHT ELSE_K if_structure {trace("if_structure", 3);}
            ;

function_call: IDENTIFIER value_paranth_list  {trace("function_call", 1);}
             ;

value_paranth_list: PARANTH_LEFT value_paranth_list__inner PARANTH_RIGHT {trace("value_paranth_list", 1);}
                  | PARANTH_LEFT PARANTH_RIGHT {trace("value_paranth_list", 2);}
                  ;

value_paranth_list__inner: value COMMA value_paranth_list__inner {trace("value_paranth_list__inner", 1);}
                         | value {trace("value_paranth_list__inner", 2);}
                         ;

return: RETURN_K value SEMICOLON {trace("return", 1);}
      | RETURN_K SEMICOLON {trace("return", 2);}
      ;

function_declaration: type_or_type_arr IDENTIFIER param_paranth_list SEMICOLON {trace("function_declaration", 1);}
                    ;

type_or_type_arr: type {trace("type_or_type_arr", 1);}
                | type_arr {trace("type_or_type_arr", 2);}
                ;

param_paranth_list: PARANTH_LEFT param_paranth_list__inner PARANTH_RIGHT {trace("param_paranth_list", 1);}
                  | PARANTH_LEFT PARANTH_RIGHT {trace("param_paranth_list", 2);}
                  ;

param_paranth_list__inner: type_or_type_arr value COMMA param_paranth_list__inner {trace("param_paranth_list__inner", 1);}
                         | type_or_type_arr value {trace("param_paranth_list__inner", 2);}
                         ;

function_definition: type_or_type_arr IDENTIFIER param_paranth_list BRACKET_LEFT subprogram BRACKET_RIGHT {trace("function_definition", 1);}
                   | type_or_type_arr IDENTIFIER param_paranth_list BRACKET_LEFT subprogram return BRACKET_RIGHT {trace("function_definition", 2);}
                   ;

struct_definition: STRUCT_K IDENTIFIER BRACKET_LEFT variable_declaration_list BRACKET_RIGHT identifier_list SEMICOLON {trace("struct_definition", 1);}
                 ;

variable_declaration_list: type_or_type_arr IDENTIFIER SEMICOLON variable_declaration_list {trace("variable_declaration_list", 1);}
                         | /* empty */ {trace("variable_declaration_list", 2);}
                         ;

identifier_list: IDENTIFIER COMMA identifier_list {trace("identifier_list", 1);}
               | IDENTIFIER {trace("identifier_list", 2);}
               | /* empty */ {trace("identifier_list", 3);}
               ;

binary_logical_operators: AMPERSANT_AMPERSANT {trace("binary_logical_operators", 1);}
                        | BAR_BAR {trace("binary_logical_operators", 2);}
                        ;

unary_logical_operators: EXCLAMATION {trace("unary_logical_operators", 1);}
                       ;

binary_relational_operators: EQUAL_EQUAL {trace("binary_relational_operators", 1);}
                           | EXCLAMATION_EQUAL {trace("binary_relational_operators", 2);}
                           | LESS_EQUAL {trace("binary_relational_operators", 3);}
                           | GREATER_EQUAL {trace("binary_relational_operators", 4);}
                           | LESS {trace("binary_relational_operators", 5);}
                           | GREATER {trace("binary_relational_operators", 6);}

binary_arithmetical_operators: PLUS {trace("binary_arithmetical_operators", 1);}
                             | MINUS {trace("binary_arithmetical_operators", 2);}
                             | STAR {trace("binary_arithmetical_operators", 3);}
                             | SLASH {trace("binary_arithmetical_operators", 4);}
                             ;

unary_arithmetical_operators: PLUS {trace("unary_arithmetical_operators", 1);}
                            | MINUS {trace("unary_arithmetical_operators", 2);}
                            ;

binary_assigment_operators: EQUAL {trace("binary_assigment_operators", 1);}
                          | PLUS_EQUAL {trace("binary_assigment_operators", 2);}
                          | MINUS_EQUAL {trace("binary_assigment_operators", 3);}
                          | STAR_EQUAL {trace("binary_assigment_operators", 4);}
                          | SLASH_EQUAL {trace("binary_assigment_operators", 5);}
                          ;

unary_assigment_operators: PLUS_PLUS {trace("binary_assigment_operators", 1);}
                         | MINUS_MINUS {trace("binary_assigment_operators", 2);}
                         ;
%%

#include "lex.yy.c"

int main(int argc, char **argv) {


    if (argc != 2) {
        printf("Usage: %s <input_file>\n", argv[0]);
        printf("Using stdin instead of file\n");
        yyin = stdin;
    }
    else {
      yyin = fopen(argv[1], "r");
      if (!yyin) {
          perror("Error opening file");
          exit(EXIT_FAILURE);
      }
    }

    int parse_result = yyparse();
    fclose(yyin);

    return parse_result;
}

void yyerror(const char *s )
{
    fprintf( stderr, "%s\n", s);
}
