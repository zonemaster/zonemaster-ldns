#include <ldns/ldns.h>

typedef struct {
    ldns_resolver *res;
} resolver_t;

typedef resolver_t *NetLDNS;
typedef ldns_pkt *NetLDNS__Packet;

NetLDNS new(char *class,char *str);
NetLDNS__Packet mxquery(NetLDNS obj, char *dname);
void DESTROY(NetLDNS obj);

char *rcode(NetLDNS__Packet obj);