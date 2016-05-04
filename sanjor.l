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
if { return(IF); }
else { return(ELSE); }
int { return(INTEGER); }
read { return(READ); }
skip { return(SKIP); }
while { return(WHILE); }
write { return(WRITE); }
{ID} { yylval.id = (char *) strdup(yytext); return(IDENTIFIER); }
[ \t\n]+ /* eat up whitespace */
. { return(yytext[0]); }

%%

int yywrap(void){
    return 1;
}

/************************** End Scanner File *****************************/ 

