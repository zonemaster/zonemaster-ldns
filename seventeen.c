#include <string.h>
#include <stdlib.h>
#include "seventeen.h"

int seventeen() {
    return SEVENTEEN;
}

size_t count(char *str) {
    return strlen(str);
}

stuff *new(char *class,char *str) {
    stuff *obj = malloc(sizeof(stuff));

    obj->n = strlen(str);
    obj->str = calloc(1+obj->n, sizeof(char));
    strncpy(obj->str, str, 1+obj->n);

    return obj;
}

char *str(NetLDNS obj) {
    return obj->str;
}