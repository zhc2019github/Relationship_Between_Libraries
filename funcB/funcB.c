#include <stdio.h>

#include "funcA.h"

extern void funcA();

void funcB() {
    printf("func B enter\n");
    funcA();
}