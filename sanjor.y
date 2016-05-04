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

    #define YYDEBUG 1 /* For Debugging */

    int yylex();
    void yyerror(const char*);

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
    void install ( char *sym_name )
    {
        symrec *s = getsym (sym_name);
        if (s == 0)
            s = putsym (sym_name);
        else {
            char message[ 100 ];
            sprintf( message, "%s is already defined\n", sym_name );
            yyerror( message );
        }
    }

    /*-------------------------------------------------------------------------
    If identifier is defined, generate code
    -------------------------------------------------------------------------*/
    int context_check( char *sym_name )
    {
        symrec *identifier = getsym( sym_name );
        return identifier->offset;
    }

    /* Used to count declarated vars on var declaration sentence */
    int nvars;

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
%token <lbls> IF WHILE /* For backpatching labels */
%token SKIP ELSE OPEN_BRACE CLOSE_BRACE
%token INTEGER READ WRITE
%token ASSGNOP

/*=========================================================================
OPERATOR PRECEDENCE
=========================================================================*/
%left '-' '+'
%left '*' '/'
%right '^'

/*=========================================================================
GRAMMAR RULES for the Simple language
=========================================================================*/

%%

program :
    commands { gen_code( HALT, 0 ); YYACCEPT; }
;

declarations :
    INTEGER id_seq IDENTIFIER ';' { install( $3 ); nvars += 1; }
;

id_seq : /* empty */
    | id_seq IDENTIFIER ',' { install( $2 ); nvars += 1; }
;

commands : /* empty */
    | commands command
;

command :
    SKIP ';'
    | { nvars = 0; } declarations {
        gen_code( DATA, nvars );
        //data_location();
    }
    | READ IDENTIFIER ';' { gen_code( READ_INT, context_check( $2 ) ); }
    | WRITE exp ';' { gen_code( WRITE_INT, 0 ); }
    | IDENTIFIER ASSGNOP exp ';' { gen_code( STORE, context_check( $1 ) ); }
    | IF bool_exp { $1 = (struct lbs *) newlblrec(); $1->for_jmp_false = reserve_loc(); }
    OPEN_BRACE commands CLOSE_BRACE { $1->for_goto = reserve_loc(); } ELSE {
        back_patch( $1->for_jmp_false, JMP_FALSE, gen_label() );
    } OPEN_BRACE commands CLOSE_BRACE { back_patch( $1->for_goto, GOTO, gen_label() ); }
    | WHILE { $1 = (struct lbs *) newlblrec(); $1->for_goto = gen_label(); }
    bool_exp { $1->for_jmp_false = reserve_loc(); } OPEN_BRACE commands CLOSE_BRACE { gen_code( GOTO, $1->for_goto );
    back_patch( $1->for_jmp_false, JMP_FALSE, gen_label() ); }
;

bool_exp :
    exp '<' exp { gen_code( LT, 0 ); }
    | exp "==" exp { gen_code( EQ, 0 ); }
    | exp '>' exp { gen_code( GT, 0 ); }
;

exp :
    NUMBER { gen_code( LD_INT, $1 ); }
    | IDENTIFIER { gen_code( LD_VAR, context_check( $1 ) ); }
    | exp '+' exp { gen_code( ADD, 0 ); }
    | exp '-' exp { gen_code( SUB, 0 ); }
    | exp '*' exp { gen_code( MULT, 0 ); }
    | exp '/' exp { gen_code( DIV, 0 ); }
    | exp '^' exp { gen_code( PWR, 0 ); }
    | '(' exp ')'
;

%%

extern struct instruction code[ MAX_MEMORY ];

/*=========================================================================
MAIN
=========================================================================*/

extern FILE *yyin;

int main( int argc, char *argv[] )
{
    if ( argc < 3 ) {
        printf("usage <input-file> <output-file>\n");
        return -1;
    }
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
    printf ("%s\n", s);
} 
/**************************** End Grammar File ***************************/
