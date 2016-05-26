/*************************************************************************** 
Scanner for the Simple language 
Author: Anthony A. Aaby
Modified by: Jordi Planes, Marc Sánchez, Meritxell Jordana
***************************************************************************/ 

%option nounput
%option noinput
%option yylineno

/*========================================================================= 
C-libraries and Token definitions 
=========================================================================*/
%{
    #include <string.h> /* for strdup */ 
    #include <stdlib.h> /* for atoi */ 
    #include "sanjor.tab.h" /* for token definitions and yylval */ 
%} 

/*========================================================================= 
TOKEN Definitions 
=========================================================================*/ 
DIGIT [0-9]
ID [a-z]([a-zA-Z0-9]|_)*
comment_block_begin \/\*
comment_block_end \*\/
comment_line \/\/(\\\n|.)*\n

/*=========================================================================
States Definitions
=========================================================================*/
%x include comment_block

/*========================================================================= 
REGULAR EXPRESSIONS defining the tokens for the Simple language 
=========================================================================*/ 
%%

{comment_line}
{comment_block_begin}    BEGIN(comment_block);
<comment_block>{comment_block_end}    BEGIN(0);
<comment_block>(.|\n)

#include(\ |\t)*\"    BEGIN(include);
<include>[^\"]*\" {
    yytext[yyleng - 1] = '\0';
    FILE* file = fopen(yytext, "r");
    if (!file) {
        fprintf(stderr, "--> ERROR: Can't open %s\n", yytext);
    } else {
        yypush_buffer_state(yy_create_buffer(file, YY_BUF_SIZE));
    }
    BEGIN(0);
}

<<EOF>> {
    yypop_buffer_state();
    if (!YY_CURRENT_BUFFER) {
        yyterminate();
    }
}

"=" { return(ASSGNOP); }
{DIGIT}+ {
    yylval.intval = atoi( yytext );
    return(NUMBER);
}
\'[^']\' {
    yylval.intval = (int) yytext[1];
    return(CHARACTER);
}
\"([^\"\\]|\\\"|\\)*\" {
	yytext[yyleng - 1] = '\0';
	yylval.id = (char *) strdup(&yytext[1]);
	return(STRING);
}
"{" { return(OPEN_BRACE); }
"}" { return(CLOSE_BRACE); }
"+" { return ADD_; }
"-" { return SUB_; }
"*" { return MUL_; }
"/" { return DIV_; }
"%" { return MOD_; }
"(" { return LPAR; }
")" { return RPAR; }
"[" { return LBRACKET; }
"]" { return RBRACKET; }
"==" { return EQ_; }
"!=" { return NQ_; }
">" { return GT_; }
"<" { return LT_; }
">=" { return GE_; }
"<=" { return LE_; }
"&&" { return AND_; }
"||" { return OR_; }
"," { return(COMMA); }
";" { return(SEMICOLON); }
if { return(IF); }
else { return(ELSE); }
int { return(INTEGER); }
char { return(CHAR); }
put { return(PUT); }
puts { return(PUTS); }
const { return(CONST); }
void { return(VOID); }
read { return(READ); }
skip { return(SKIP); }
length { return(LENGTH); }
while { return(WHILE); }
write { return(WRITE); }
"return" { return(RETURN); }
{ID} { yylval.id = (char *) strdup(yytext); return(IDENTIFIER); }
[ \t\n]+ /* eat up whitespace */

%%

int yywrap(void){
    return 1;
}

/************************** End Scanner File *****************************/ 

