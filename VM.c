/*************************************************************************** 
Virtual Machine 
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
  
  read_bytecode( argv[1] );
  #ifndef NDEBUG
    printf("[ INFO ] Debug mode enabled. Pres INTRO to execute next INST.\n");
  #endif
  fetch_execute_cycle();

  return 0;
}
