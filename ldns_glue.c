#include <string.h>
#include <stdlib.h>
#include <ldns/ldns.h>
#include "ldns_glue.h"

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

/*
 *  NetLDNS functions
 */

NetLDNS new(char *class, char *str) {
    NetLDNS obj;
    ldns_rdf *ns;
    ldns_status s;

    Newxz(obj,1,resolver_t);
    ns = ldns_rdf_new_frm_str(LDNS_RDF_TYPE_A, str);
    obj->res = ldns_resolver_new();
    s = ldns_resolver_push_nameserver(obj->res, ns);
    if( s != LDNS_STATUS_OK)
    {
        croak("Some sort of error: %s", ldns_get_errorstr_by_id(s));
    }

    return obj;
}

NetLDNS__Packet query(NetLDNS obj, char *dname, char *rrtype, char *rrclass) {
    ldns_rdf *domain;
    ldns_rr_type t;
    ldns_rr_class c;
    NetLDNS__Packet p;

    t = ldns_get_rr_type_by_name(rrtype);
    if(!t)
    {
        croak("Unknown RR type: %s", rrtype);
    }

    c = ldns_get_rr_class_by_name(rrclass);
    if(!c)
    {
        croak("Unknown RR class: %s", rrclass);
    }

    domain = ldns_dname_new_frm_str(dname);
    p = ldns_resolver_query(obj->res, domain, t, c, LDNS_RD);

    return p;
}