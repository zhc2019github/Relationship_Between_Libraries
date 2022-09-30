/*整个流程就是主函数调用 funcB，然后funcB 调用funcA
 //////* */
#include <stdio.h>
#include "funcB.h"
int main() {
  printf("main\n");
  funcB();

  return 0;
}
