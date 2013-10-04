#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "ldns_glue.h"

MODULE = NetLDNS        PACKAGE = NetLDNS

PROTOTYPES: ENABLE

NetLDNS
new(class,str)
    char *class;
    char *str;

NetLDNS::Packet
mxquery(obj,dname)
    NetLDNS obj;
    char *dname;

void
DESTROY(obj)
        NetLDNS obj;

MODULE = NetLDNS        PACKAGE = NetLDNS::Packet PREFIX=packet_

char *
packet_rcode(obj)
    NetLDNS::Packet obj;

void
packet_DESTROY(obj)
    NetLDNS::Packet obj;
