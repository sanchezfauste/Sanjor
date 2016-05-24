/*************************************************************************
Compiler for the Simple language
Author: Anthony A. Aaby
Modified by: Jordi Planes, Marc Sánchez, Meritxell Jordana
***************************************************************************/

%{

    /*=========================================================================
    C Libraries, Symbol Table, Code Generator & other C code
    =========================================================================*/
    #include <stdio.h> /* For I/O */
    #include <stdlib.h> /* For malloc here and in symbol table */
    #include <string.h> /* For strcmp in symbol table */
    #include "ST.h" /* Symbol Table */
    #include "SM.h" /* Stack Machine */
    #include "CG.h" /* Code Generator */
    #include "environment.h"
    #include "functions.h"

    #define YYDEBUG 1 /* For Debugging */

    int yylex();
    void yyerror(const char*);

    Environment *current_env;
    Functions *functions;

    int errors; /* Error Count */
    /*-------------------------------------------------------------------------
    The following support backpatching
    -------------------------------------------------------------------------*/
    struct lbs /* Labels for data, if and while */
    {
        int for_goto;
        int for_jmp_false;
    };

    struct lbs * newlblrec() /* Allocate space for the labels */
    {
        return (struct lbs *) malloc(sizeof(struct lbs));
    }

    /*-------------------------------------------------------------------------
    Install identifier & check if previously defined.
    -------------------------------------------------------------------------*/
    void install ( char *sym_name, int size = 1 )
    {
        if (!current_env->add_var(sym_name, size)) {
            char message[ 100 ];
            sprintf( message, "var <%s> is already defined", sym_name );
            yyerror( message );
        }
    }

    /*-------------------------------------------------------------------------
    If identifier is defined, generate code
    -------------------------------------------------------------------------*/
    int context_check( char *sym_name, int offset = 0 )
    {
        if (current_env->check_var(sym_name)) {
            if (!current_env->check_var_offset(sym_name, offset)) {
                char message[ 100 ];
                sprintf( message, "try to accessing out of bounds var <%s>", sym_name );
                yyerror( message );
                return -1;
            }
            return current_env->get_var(sym_name, offset);
        } else {
            char message[ 100 ];
            sprintf( message, "var <%s> is not defined", sym_name );
            yyerror( message );
            return -1;
        }
    }

    /* Used to count declarated vars on var declaration sentence */
    int nvars = 0;

%}

/*=========================================================================
SEMANTIC RECORDS 
=========================================================================*/
%union /* The Semantic Records */
{
    int intval; /* Integer values */
    char *id; /* Identifiers */
    struct lbs *lbls; /* For backpatching */
};

/*=========================================================================
TOKENS
=========================================================================*/
%start program
%token <intval> NUMBER /* Simple integer */
%token <id> IDENTIFIER /* Simple identifier */
%token <lbls> IF WHILE INTEGER /* For backpatching labels */
%token SKIP ELSE OPEN_BRACE CLOSE_BRACE
%token READ WRITE
%token ASSGNOP
%token EQ_ NQ_ GT_ LT_ LE_ GE_
%token ADD_ SUB_ MUL_ DIV_ PWR_ MOD_
%token LPAR RPAR LBRACKET RBRACKET
%token COMMA SEMICOLON
%token RETURN LENGTH

/*=========================================================================
OPERATOR PRECEDENCE
=========================================================================*/
%left SUB_ ADD_
%left MUL_ DIV_ MOD_
%right PWR_

/*=========================================================================
GRAMMAR RULES for the Simple language
=========================================================================*/

%%

program :
    commands { gen_code( HALT, 0 ); YYACCEPT; }
;

declarations :
    INTEGER IDENTIFIER { install( $2 ); nvars += 1; } id_seq SEMICOLON
    | INTEGER IDENTIFIER LBRACKET NUMBER RBRACKET { install( $2, $4 ); nvars += $4; } id_seq SEMICOLON
;

id_seq : /* empty */
    | id_seq COMMA IDENTIFIER { install( $3 ); nvars += 1; }
    | id_seq COMMA IDENTIFIER LBRACKET NUMBER RBRACKET { install( $3, $5 ); nvars += $5; }
;

function_vars :
    | INTEGER IDENTIFIER function_vars { install( $2 ); nvars += 1; }
    | COMMA INTEGER IDENTIFIER function_vars { install( $3 ); nvars += 1; }
;

commands : /* empty */
    | commands command
;

parameters :
    | param_list exp {
        gen_code( STORE_TOF, nvars + 3 );
        nvars += 1;
    }
;

param_list : /* empty */
    | param_list exp COMMA {
        gen_code( STORE_TOF, nvars + 3 );
        nvars += 1;
    }
;

command :
    SKIP SEMICOLON
    | declarations {
        gen_code( DATA, nvars );
        nvars = 0;
        //data_location();
    }
    | READ IDENTIFIER SEMICOLON { gen_code( READ_INT, context_check( $2 ) ); }
    | WRITE exp SEMICOLON { gen_code( WRITE_INT, 0 ); }
    | IDENTIFIER ASSGNOP exp SEMICOLON { gen_code( STORE, context_check( $1 ) ); }
    | IDENTIFIER LBRACKET exp RBRACKET ASSGNOP exp SEMICOLON { gen_code( STORE_ARRAY, context_check( $1 ) ); }
    | IF LPAR bool_exp RPAR { $1 = (struct lbs *) newlblrec(); $1->for_jmp_false = reserve_loc(); }
    OPEN_BRACE commands CLOSE_BRACE { $1->for_goto = reserve_loc(); } ELSE {
        back_patch( $1->for_jmp_false, JMP_FALSE, gen_label() );
    } OPEN_BRACE commands CLOSE_BRACE { back_patch( $1->for_goto, GOTO, gen_label() ); free($1); }
    | WHILE { $1 = (struct lbs *) newlblrec(); $1->for_goto = gen_label(); }
    LPAR bool_exp RPAR { $1->for_jmp_false = reserve_loc(); }
    OPEN_BRACE commands CLOSE_BRACE { gen_code( GOTO, $1->for_goto );
    back_patch( $1->for_jmp_false, JMP_FALSE, gen_label() ); free($1); }
    | RETURN exp SEMICOLON {
        gen_code( STORE, -3 );
        gen_code( POP, current_env->get_nvars() );
        gen_code( RET, 0 );
    }
    | INTEGER IDENTIFIER LPAR {
        $1 = (struct lbs *) newlblrec();
        $1->for_goto = reserve_loc();
        current_env = new Environment(current_env);
        if (!functions->add_function($2, gen_label())) {
            char message[ 100 ];
            sprintf( message, "function <%s> is already defined", $2 );
            yyerror( message );
        }
    } function_vars RPAR OPEN_BRACE { gen_code( DATA, nvars ); nvars = 0; }
        commands CLOSE_BRACE {
            current_env = current_env->get_previous_environment();
            back_patch( $1->for_goto, GOTO, gen_label() );
            free($1);
        }
;

bool_exp :
    exp LT_ exp { gen_code( LT, 0 ); }
    | exp EQ_ exp { gen_code( EQ, 0 ); }
    | exp GT_ exp { gen_code( GT, 0 ); }
;

exp :
    NUMBER { gen_code( LD_INT, $1 ); }
    | IDENTIFIER { gen_code( LD_VAR, context_check( $1 ) ); }
    | IDENTIFIER LBRACKET exp RBRACKET { gen_code( LD_VAR_ARRAY, context_check( $1 ) ); }
    | exp ADD_ exp { gen_code( ADD, 0 ); }
    | exp SUB_ exp { gen_code( SUB, 0 ); }
    | exp MUL_ exp { gen_code( MULT, 0 ); }
    | exp DIV_ exp { gen_code( DIV, 0 ); }
    | exp PWR_ exp { gen_code( PWR, 0 ); }
    | LPAR exp RPAR
    | IDENTIFIER LPAR parameters { nvars = 0; } RPAR {
        int function_offset = functions->get_function_offset($1);
        if (function_offset == -1) {
            char message[ 100 ];
            sprintf( message, "function <%s> is not defined", $1 );
            yyerror( message );
        }
        gen_code( CALL, function_offset );
    }
    | LENGTH LPAR IDENTIFIER RPAR {
        gen_code( LD_INT, current_env->get_var_length($3) );
    }
;

%%

extern struct instruction code[ MAX_MEMORY ];

/*=========================================================================
MAIN
=========================================================================*/

extern FILE *yyin;
extern int yylineno;

int main( int argc, char *argv[] )
{
    if ( argc < 3 ) {
        printf("usage <input-file> <output-file>\n");
        return -1;
    }
    current_env = new Environment(NULL);
    functions = new Functions();
    yyin = fopen( argv[1], "r" );
    /*yydebug = 1;*/
    errors = 0;
    printf("Sanjor Compiler\n");
    yyparse ();
    printf ( "Parse Completed\n" );
    if ( errors == 0 )
    {
        //print_code ();
        //fetch_execute_cycle();
        write_bytecode( argv[2] );
    }
    return 0;
}

/*========================================================================= 
YYERROR 
=========================================================================*/ 
void yyerror ( const char *s ) /* Called by yyparse on error */
{
    errors++; 
    printf ("--> Error on line %i: %s\n", yylineno, s);
} 
/**************************** End Grammar File ***************************/
