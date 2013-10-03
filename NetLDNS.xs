#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "seventeen.h"

MODULE = NetLDNS        PACKAGE = NetLDNS

PROTOTYPES: ENABLE

int
seventeen()

void
count(str)
    char * str
    PREINIT:
        int n;
    PPCODE:
        n = count(str);
        EXTEND(SP,2);
        PUSHs(sv_2mortal(newSVnv(n  )));
        PUSHs(sv_2mortal(newSVpv(str,n)));


NetLDNS
new(class,str)
    char *class;
    char *str;

char *
str(obj)
        NetLDNS obj;