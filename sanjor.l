/*************************************************************************** 
Scanner for the Simple language 
Author: Anthony A. Aaby
Modified by: Jordi Planes, Marc Sánchez, Meritxell Jordana
***************************************************************************/ 

%option nounput
%option noinput

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

/*========================================================================= 
REGULAR EXPRESSIONS defining the tokens for the Simple language 
=========================================================================*/ 
%% 

"=" { return(ASSGNOP); }
{DIGIT}+ {
    yylval.intval = atoi( yytext );
    return(NUMBER);
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
"==" { return EQ_; }
"!=" { return NQ_; }
">" { return GT_; }
"<" { return LT_; }
">=" { return GE_; }
"<=" { return LE_; }
"," { return(COMMA); }
";" { return(SEMICOLON); }
if { return(IF); }
else { return(ELSE); }
int { return(INTEGER); }
read { return(READ); }
skip { return(SKIP); }
while { return(WHILE); }
write { return(WRITE); }
{ID} { yylval.id = (char *) strdup(yytext); return(IDENTIFIER); }
[ \t\n]+ /* eat up whitespace */

%%

int yywrap(void){
    return 1;
}

/************************** End Scanner File *****************************/ 

