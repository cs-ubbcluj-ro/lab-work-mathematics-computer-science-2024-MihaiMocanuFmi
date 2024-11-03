%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

typedef enum{
    BIN_LT = 0,
	BIN_LE,
	BIN_EQ,
	BIN_GE,
	BIN_GT,
	BIN_ASSIGN,
	BIN_ADD_ASSIGN,
	BIN_SUB_ASSIGN,
	BIN_MUL_ASSIGN,
	BIN_DIV_ASSIGN,
	BIN_ADD,
	BIN_SUB,
	BIN_MUL,
	BIN_DIV,
	UNI_INCR,
	UNI_DEINCR,
	BIN_OR,
	BIN_AND,
	UNI_NOT,
	VOID_K,
	CHAR_K,
	INT_K,
	DOUBLE_K,
	CONST_K,
	IF_K,
	ELSE_K,
	WHILE_K,
	RETURN_K,
	STRUCT_K,
	MAIN_K,
	READ_K,
	WRITE_K,
	IDENTIFIER,
	INTEGER,
	REAL,
	CHAR,
	STR_LIT,
	BRACKET_LEFT,
	BRACKET_RIGHT,
	PARANTH_LEFT,
	PARANTH_RIGHT,
	COMMA,
	END_INSTR,
	TOKEN_COUNT
} TokenE;

typedef struct {
    TokenE type;
    const char* code;
    size_t index;
} TokenT;


static size_t currentLine = 0;
static size_t error = 0;

#define MAX_ST_LENGHT 100
static const char* ST[MAX_ST_LENGHT];
static size_t ST_length = 0;

static size_t ST_add(const char* tokenCode) {
    for (size_t i = 0; i < ST_length; ++i)
    {
        if (strcmp(tokenCode, ST[i]) == 0)
            return i;
    }
    ST[ST_length] = tokenCode;
    return ST_length++;
}

static void ST_show(void) {
    printf("Symbol table (size: %lu):\n", ST_length);
    printf("ST Index\tCode\n");
    for (size_t i = 0; i < ST_length; i++)
    {
        printf("%X\t\t%s\n", i, ST[i]);
    }
}

#define MAX_PIF_LENGHT 100
static TokenT PIF[MAX_PIF_LENGHT];
static size_t PIF_length = 0;

static void PIF_add(TokenT token) {

    PIF[PIF_length++] = token;
}

static void PIF_show(void) {
    printf("Program intermediate form (size: %lu):\n", PIF_length);
    printf("Row No\tType Id\tST Index\tCode\n");
    for (size_t i = 0; i < PIF_length; i++)
    {
        if(PIF[i].index == -1)
            printf("%lu:\t%lu\t%X\t%s\n", i, PIF[i].type, PIF[i].index, PIF[i].code);
        else
            printf("%lu:\t%lu\t%X\t\t%s\n", i, PIF[i].type, PIF[i].index, PIF[i].code);

    }
}

static void PIF_cleanup(void) {
    for (size_t i = 0; i < PIF_length; i++)
    {
       free((void*)PIF[i].code);
    }
}

%}

digit       [0-9]
letter      [A-Za-z]
whitesp     [ \t\n]+

%%

"<"         {printf(" BIN_LT"); PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = BIN_LT, }); }
"<="        {printf(" BIN_LE"); PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = BIN_LE, }); }
"=="        {printf(" BIN_EQ"); PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = BIN_EQ, }); }
">="        {printf(" BIN_GE"); PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = BIN_GE, }); }
">"         {printf(" BIN_GT"); PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = BIN_GT, }); }

"="         {printf(" BIN_ASSIGN");      PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = BIN_ASSIGN,      }); }
"+="        {printf(" BIN_ADD_ASSIGN");  PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = BIN_ADD_ASSIGN,  }); }
"-="        {printf(" BIN_SUB_ASSIGN");  PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = BIN_SUB_ASSIGN,  }); }
"*="        {printf(" BIN_MUL_ASSIGN");  PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = BIN_MUL_ASSIGN,  }); }
"/="        {printf(" BIN_DIV_ASSIGN");  PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = BIN_DIV_ASSIGN,  }); }

"+"         {printf(" BIN_ADD"); PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = BIN_ADD, }); }
"-"         {printf(" BIN_SUB"); PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = BIN_SUB, }); }
"*"         {printf(" BIN_MUL"); PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = BIN_MUL, }); }
"/"         {printf(" BIN_DIV"); PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = BIN_DIV, }); }

"++"        {printf(" UNI_INCR");    PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = UNI_INCR,    }); }
"--"        {printf(" UNI_DEINCR");  PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = UNI_DEINCR,  }); }

"||"        {printf(" BIN_OR");  PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = BIN_OR,  }); }
"&&"        {printf(" BIN_AND"); PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = BIN_AND, }); }

"!"         {printf(" UNI_NOT"); PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = UNI_NOT, }); }

"void"      {printf(" VOID_K");      PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = VOID_K,  }); }
"char"      {printf(" CHAR_K");      PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = CHAR_K,  }); }
"int"       {printf(" INT_K");       PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = INT_K,   });}
"double"    {printf(" DOUBLE_K");    PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = DOUBLE_K,}); }
"const"     {printf(" CONST_K");     PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = CONST_K, }); }
"if"        {printf(" IF_K");        PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = IF_K,    }); }
"else"      {printf(" ELSE_K");      PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = ELSE_K,  }); }
"while"     {printf(" WHILE_K");     PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = WHILE_K, }); }
"return"    {printf(" RETURN_K");    PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = RETURN_K,}); }
"struct"    {printf(" STRUCT_K");    PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = STRUCT_K,}); }
"main"      {printf(" MAIN_K");      PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = MAIN_K,  }); }
"read"      {printf(" READ_K");      PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = READ_K,  }); }
"write"     {printf(" WRITE_K");     PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = WRITE_K, }); }

[_a-zA-Z][_a-zA-Z0-9]*              {printf(" IDENTIFIER");  const char* code = strdup(yytext); PIF_add((TokenT){.code = code, .index = ST_add(code), .type = IDENTIFIER,  }); }
[+-]?(([1-9][0-9]+)|[0-9])          {printf(" INTEGER");     const char* code = strdup(yytext); PIF_add((TokenT){.code = code, .index = ST_add(code), .type = INTEGER,     }); }
[+-]?(([1-9][0-9]+)|[0-9])\.[0-9]+  {printf(" REAL");        const char* code = strdup(yytext); PIF_add((TokenT){.code = code, .index = ST_add(code), .type = REAL,        }); }

'.'         {printf(" CHAR");    const char* code = strdup(yytext); PIF_add((TokenT){.code = code, .index = ST_add(code), .type = CHAR,  }); }
\".*\"      {printf(" STR_LIT"); const char* code = strdup(yytext); PIF_add((TokenT){.code = code, .index = ST_add(code), .type = STR_LIT,  }); }

"{"         {printf(" BRACKET_LEFT");    PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = BRACKET_LEFT,    }); }
"}"         {printf(" BRACKET_RIGHT");   PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = BRACKET_RIGHT,   }); }
"("         {printf(" PARANTH_LEFT");    PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = PARANTH_LEFT,    }); }
")"         {printf(" PARANTH_RIGHT");   PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = PARANTH_RIGHT,   }); }
","         {printf(" COMMA");           PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = COMMA,           }); }
";"         {printf(" END_INSTR");        PIF_add((TokenT){.code = strdup(yytext), .index = -1, .type = END_INSTR,      }); }

[ \t]+      {printf(" WS"); /* ignore whitespace */}
[\r]        {}
[\n]        {printf("\n"); ++currentLine;}
.           {++error; printf("\nIllegal token %lu: %s \n\tFound on line number: %lu\n\tHelpful hint: Learn how to write...\n", error, yytext, currentLine);}

%%

int yywrap(void) {
    return 1;
}

int main(int argc, char** argv) {

	FILE *fp;
	fp = fopen(argv[1], "r");

	/* yyin - takes the file pointer which contains the input*/
	yyin = fp;

	/* yylex() - this is the main flex function which runs the Rule Section*/
	yylex();

    printf("\n\nFinished parsing %lu lines. Encountered %lu errors\n\n", currentLine, error);

    ST_show();
    printf("\n");
    PIF_show();
    PIF_cleanup();
	return 0;
}
