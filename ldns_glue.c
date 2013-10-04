#include <string.h>
#include <stdlib.h>
#include <ldns/ldns.h>
#include "ldns_glue.h"

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

NetLDNS new(char *class, char *str) {
    NetLDNS obj = malloc(sizeof(resolver_t));
    ldns_rdf *ns;
    ldns_status s;

    ns = ldns_rdf_new_frm_str(LDNS_RDF_TYPE_A, str);
    obj->res = ldns_resolver_new();
    s = ldns_resolver_push_nameserver(obj->res, ns);
    if( s != LDNS_STATUS_OK)
    {
        croak("Some sort of error");
    }

    return obj;
}

NetLDNS__Packet mxquery(NetLDNS obj, char *dname) {
    ldns_rdf *domain;
    NetLDNS__Packet p;

    domain = ldns_dname_new_frm_str(dname);
    p = ldns_resolver_query(obj->res, domain, LDNS_RR_TYPE_MX, LDNS_RR_CLASS_IN, LDNS_RD);

    return p;
}

void DESTROY(NetLDNS obj) {
    fprintf(stderr,"DESTROY called on %p.\n", (void *)obj);
    ldns_resolver_deep_free(obj->res);
    free(obj);
}

char *packet_rcode(NetLDNS__Packet obj){
    ldns_buffer *tmp = ldns_buffer_new(0);
    ldns_pkt_rcode2buffer_str(tmp, ldns_pkt_get_rcode(obj));

    return ldns_buffer_export(tmp);    
}

void packet_DESTROY(NetLDNS__Packet obj) {
    fprintf(stderr,"packet_DESTROY called on %p.\n", (void *)obj);
    ldns_pkt_free(obj);
}