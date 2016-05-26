/*************************************************************************** 
Stack Machine 
Author: Anthony A. Aaby
Modified by: Jordi Planes, Marc Sánchez, Meritxell Jordana
***************************************************************************/ 

#include <stdio.h>
#include "SM.h"

/* OPERATIONS: External Representation */ 
char const *op_name[] = {
	"halt", "store", "jmp_false", "goto", "call", "ret", "data", "ld_int",
	"ld_var", "in_int", "out_int", "lt", "eq", "gt", "add", "sub", "mult",
	"div", "pwr", "pop", "store_tof", "ld_var_array", "store_array",
	"write_char", "write_string", "nq", "le", "ge", "and", "or"
}; 

/* CODE Array */ 
struct instruction code[MAX_MEMORY];

/* RUN-TIME Stack */ 
int stack[MAX_MEMORY];

/*------------------------------------------------------------------------- 
  Registers 
  -------------------------------------------------------------------------*/ 
int pc = 0; 
struct instruction ir; 
int ar = 0; 
int top = -1; 
char ch; 

#ifndef NDEBUG
void print_stack() {
	int i;
	printf("    ┌───── STACK ─────┐\n");
	for (i = top; i >= 0; i--) {
		printf("%3i │ %-15i │", i, stack[i]);
		if (i == top) {
			printf(" <-- top");
		}
		if (i == ar) {
			printf(" <-- ar");
		}
		if (i > 0) printf("\n    ├─────────────────┤\n");
	}
	if (top == -1) printf("    │   -- EMPTY --   │");
	printf("\n    └─────────────────┘\n");
}
#endif

/*========================================================================= 
  Fetch Execute Cycle 
  =========================================================================*/ 
void fetch_execute_cycle() 
{ 
  do {
    /* Fetch */ 
    ir = code[pc++];
    /* Execute */ 
	#ifndef NDEBUG
		char unused;
		print_stack();
		scanf("%c", &unused);
		printf("\n[ INST ] %3d: %-10s %4i\n", pc-1, op_name[(int) ir.op], ir.arg);
	#endif
    switch (ir.op) { 
    case HALT : printf( "--> halt\n" ); break; 
    case READ_INT : printf( "--> Input: " ); 
      scanf( "%d", &stack[ar+ir.arg] ); break; 
    case WRITE_INT : printf( "--> Output: %d\n", stack[top--] ); break; 
    case WRITE_CHAR : printf( "--> Output: %c\n", stack[top--] ); break;
    case WRITE_STRING :
         printf( "--> Output: " );
         int i;
         for (i = 0; stack[ar+ir.arg+i] != 0; i++) {
             printf("%c", stack[ar+ir.arg+i]);
         }
         printf( "\n" );
         break;
    case STORE : stack[ar+ir.arg] = stack[top--]; break; 
    case STORE_ARRAY : stack[ar+ir.arg+stack[top-1]] = stack[top]; top -= 2; break;
	case STORE_TOF : stack[top+ir.arg] = stack[top]; top--; break; 
    case JMP_FALSE : if ( stack[top--] == 0 ) 
	pc = ir.arg; 
      break; 
    case GOTO : pc = ir.arg; break; 
    case CALL :
        top++; //For store return value
        stack[++top] = pc;
        stack[++top] = ar;
        ar = top + 1;
        pc = ir.arg;
        break;
    case RET :
        ar = stack[top--];
        pc = stack[top--];
        break;
    case DATA : top = top + ir.arg; break; 
    case LD_INT : stack[++top] = ir.arg; break; 
    case LD_VAR : stack[++top] = stack[ar+ir.arg]; break; 
    case LD_VAR_ARRAY : stack[top] = stack[ar+ir.arg+stack[top]]; break;
    case LT : if ( stack[top-1] < stack[top] ) 
	stack[--top] = 1; 
      else stack[--top] = 0; 
      break; 
    case NQ :
        if ( stack[top-1] != stack[top] ) stack[--top] = 1;
        else stack[--top] = 0;
        break;
    case LE :
        if ( stack[top-1] <= stack[top] ) stack[--top] = 1;
        else stack[--top] = 0;
        break;
    case GE :
        if ( stack[top-1] >= stack[top] ) stack[--top] = 1;
        else stack[--top] = 0;
        break;
    case EQ : if ( stack[top-1] == stack[top] ) 
	stack[--top] = 1; 
      else stack[--top] = 0; 
      break; 
    case GT : if ( stack[top-1] > stack[top] ) 
	stack[--top] = 1; 
      else stack[--top] = 0; 
      break; 
    case AND :
        if ( stack[top-1] == 1 && stack[top] == 1 ) stack[--top] = 1;
        else stack[--top] = 0;
        break;
    case OR :
        if ( stack[top-1] == 1 || stack[top] == 1 ) stack[--top] = 1;
        else stack[--top] = 0;
        break;
    case ADD : stack[top-1] = stack[top-1] + stack[top]; 
      top--; 
      break; 
    case SUB : stack[top-1] = stack[top-1] - stack[top]; 
      top--; 
      break; 
    case MULT : stack[top-1] = stack[top-1] * stack[top]; 
      top--; 
      break; 
    case DIV : stack[top-1] = stack[top-1] / stack[top]; 
      top--; 
      break; 
    case PWR : stack[top-1] = stack[top-1] * stack[top]; 
      top--; 
      break; 
    case POP : top -= ir.arg; break;
    default : printf( "%d Internal Error: Memory Dump\n", ir.op ); 
      break; 
    } 
  } 
  while (ir.op != HALT); 
} 
/*************************** End Stack Machine **************************/ 
