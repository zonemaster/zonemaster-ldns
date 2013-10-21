#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <ldns/ldns.h>

typedef struct {
    ldns_resolver *res;
} resolver_t;

typedef resolver_t *NetLDNS;
typedef ldns_pkt *NetLDNS__Packet;
typedef ldns_rr *NetLDNS__RR;
typedef ldns_rr *NetLDNS__RR__NS;
typedef ldns_rr *NetLDNS__RR__A;
typedef ldns_rr *NetLDNS__RR__AAAA;
typedef ldns_rr *NetLDNS__RR__SOA;
typedef ldns_rr *NetLDNS__RR__MX;
typedef ldns_rr *NetLDNS__RR__DS;
typedef ldns_rr *NetLDNS__RR__DNSKEY;
typedef ldns_rr *NetLDNS__RR__RRSIG;
typedef ldns_rr *NetLDNS__RR__NSEC;
typedef ldns_rr *NetLDNS__RR__NSEC3;
typedef ldns_rr *NetLDNS__RR__NSECPARAM;
typedef ldns_rr *NetLDNS__RR__PTR;
typedef ldns_rr *NetLDNS__RR__CNAME;
typedef ldns_rr *NetLDNS__RR__TXT;

NetLDNS new(char *class,char *str);
NetLDNS__Packet query(NetLDNS obj, char *dname, char *rrtype, char *rrclass);
void DESTROY(NetLDNS obj);

SV *packet_rcode(NetLDNS__Packet obj);
void packet_DESTROY(NetLDNS__Packet obj);

SV *rr_owner(NetLDNS__RR obj);
void rr_DESTROY(NetLDNS__RR obj);