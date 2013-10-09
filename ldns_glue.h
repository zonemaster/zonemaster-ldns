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

NetLDNS new(char *class,char *str);
NetLDNS__Packet mxquery(NetLDNS obj, char *dname);
NetLDNS__Packet query(NetLDNS obj, char *dname, char *rrtype, char *rrclass);
void DESTROY(NetLDNS obj);

SV *packet_rcode(NetLDNS__Packet obj);
bool packet_qr(NetLDNS__Packet obj);
void packet_DESTROY(NetLDNS__Packet obj);

SV *rr_owner(NetLDNS__RR obj);
void rr_DESTROY(NetLDNS__RR obj);