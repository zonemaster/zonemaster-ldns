#include <ldns/ldns.h>

typedef struct {
    ldns_resolver *res;
} resolver_t;

typedef resolver_t *NetLDNS;

NetLDNS new(char *class,char *str);
char *mxquery(NetLDNS obj, char *dname);
void DESTROY(NetLDNS obj);