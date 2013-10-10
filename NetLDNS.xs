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

SV *
packet_rcode(obj)
    NetLDNS::Packet obj;

bool
packet_qr(obj)
    NetLDNS::Packet obj;
    CODE:
        RETVAL = ldns_pkt_qr(obj);
    OUTPUT:
        RETVAL

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
            char rrclass[30];
            char *type;

            ldns_rr *rr = ldns_rr_clone(ldns_rr_list_rr(rrs,i));

            type = ldns_rr_type2str(ldns_rr_get_type(rr));
            snprintf(rrclass, 30, "NetLDNS::RR::%s", type);

            SV* rr_sv = sv_newmortal();
            sv_setref_pv(rr_sv, rrclass, rr);
            PUSHs(rr_sv);
            Safefree(type);
        }
    }

void
packet_DESTROY(obj)
    NetLDNS::Packet obj;



MODULE = NetLDNS        PACKAGE = NetLDNS::RR           PREFIX=rr_

SV *
rr_owner(obj)
    NetLDNS::RR obj;

U32
rr_ttl(obj)
    NetLDNS::RR obj;
    CODE:
        RETVAL = ldns_rr_ttl(obj);
    OUTPUT:
        RETVAL

char *
rr_type(obj)
    NetLDNS::RR obj;
    CODE:
        RETVAL = ldns_rr_type2str(ldns_rr_get_type(obj));
    OUTPUT:
        RETVAL

char *
rr_class(obj)
    NetLDNS::RR obj;
    CODE:
        RETVAL = ldns_rr_class2str(ldns_rr_get_class(obj));
    OUTPUT:
        RETVAL

char *
rr_string(obj)
    NetLDNS::RR obj;
    CODE:
        RETVAL = ldns_rr2str(obj);
    OUTPUT:
        RETVAL

void
rr_DESTROY(obj)
    NetLDNS::RR obj;


MODULE = NetLDNS        PACKAGE = NetLDNS::RR::NS           PREFIX=rr_ns_

char *
rr_ns_nsdname(obj)
    NetLDNS::RR::NS obj;
    CODE:
        RETVAL = ldns_rdf2str(ldns_rr_rdf(obj, 0));
    OUTPUT:
        RETVAL
