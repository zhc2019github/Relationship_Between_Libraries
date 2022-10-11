/*整个流程就是主函数调用 funcB，然后funcB 调用funcA
 ///////
 //
 //
 //test merge commit second time
 //* */
// this is master commit
#include <stdio.h>
#include "funcB.h"
int main() {
  printf("main\n");
  funcB();
//this is a merge test
  return 0;
  // this is a test2 rebase
}
