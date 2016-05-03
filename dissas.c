/*************************************************************************** 
Dissassembler 
Author: Anthony A. Aaby
Modified by: Jordi Planes, Marc Sánchez, Meritxell Jordana
***************************************************************************/ 

#include <stdio.h>
#include "SM.h"
#include "CG.h"

int main( int argc, char *argv[] ) {
  if ( argc < 2 ) {
    printf( "usage: %s <bytecode-file>\n", argv[0] );
    return 1;
  }  

  printf("Dissassembler\n");
  read_bytecode( argv[1] );
  print_code();

  return 0;
}

