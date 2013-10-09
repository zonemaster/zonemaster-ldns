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

NetLDNS::Packet
query(obj, dname, rrtype, rrclass)
    NetLDNS obj;
    char *dname;
    char *rrtype;
    char *rrclass;

void
DESTROY(obj)
        NetLDNS obj;




MODULE = NetLDNS        PACKAGE = NetLDNS::Packet           PREFIX=packet_

char *
packet_rcode(obj)
    NetLDNS::Packet obj;

bool
packet_qr(obj)
    NetLDNS::Packet obj;

void
packet_answer(obj)
    NetLDNS::Packet obj;
    PPCODE:
    {
        size_t i,n;
        ldns_rr_list *rrs;

        rrs = ldns_pkt_answer(obj);
        n = ldns_rr_list_rr_count(rrs);

        EXTEND(sp,n);
        for(size_t i = 0; i < n; ++i)
        {
            SV* rr_sv = sv_newmortal();
            sv_setref_pv(rr_sv, "NetLDNS::RR", ldns_rr_clone(ldns_rr_list_rr(rrs,i)));
            PUSHs(rr_sv);
        }
    }

void
packet_DESTROY(obj)
    NetLDNS::Packet obj;



MODULE = NetLDNS        PACKAGE = NetLDNS::RR           PREFIX=rr_

void
rr_DESTROY(obj)
    NetLDNS::RR obj;
