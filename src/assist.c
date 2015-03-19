#include <LDNS.h>

#define RESOLVER_HASH_NAME "Net::LDNS::__resolvers__"

void
    net_ldns_remember_resolver(SV *rv)
{
    HV *hash;
    SV *val;
    STRLEN keylen;
    char *keystr;

    hash = get_hv(RESOLVER_HASH_NAME, GV_ADD);
    val = newRV_inc(SvRV(rv));
    keystr = SvPV(val,keylen);
    sv_rvweaken(val);
    hv_store(hash, keystr, keylen, val, 0);
}

void net_ldns_clone_resolvers()
{
    HV *hash;
    HE *entry;

    hash = get_hv(RESOLVER_HASH_NAME, GV_ADD);
    hv_iterinit(hash);
    while ( (entry = hv_iternext(hash)) != NULL )
    {
        SV *val = hv_iterval(hash, entry);
        if(val!=NULL)
        {
            ldns_resolver *old = INT2PTR(ldns_resolver *, SvIV((SV *)SvRV(val)));
            ldns_resolver *new = ldns_resolver_clone(old);
            sv_setiv_mg(SvRV(val), PTR2IV(new));
        }
        else
        {
            SV *key = hv_iterkeysv(entry);
            hv_delete_ent(hash, key, G_DISCARD, 0);
        }
    }
}

char *
    randomize_capitalization(char *in)
{
#ifdef RANDOMIZE
    char *str;
    str = in;
    while(*str) {
        if(Drand01() < 0.5)
        {
            *str = tolower(*str);
        }
        else
        {
            *str = toupper(*str);
        }
        str++;
    }
#endif
    return in;
}

SV *
    rr2sv(ldns_rr *rr)
{
    char rrclass[30];
    char *type;

    type = ldns_rr_type2str(ldns_rr_get_type(rr));
    snprintf(rrclass, 30, "Net::LDNS::RR::%s", type);

    SV* rr_sv = newSV(0);
    if (strncmp(type, "TYPE", 4)==0)
    {
        sv_setref_pv(rr_sv, "Net::LDNS::RR", rr);
    }
    else
    {
        sv_setref_pv(rr_sv, rrclass, rr);
    }

    free(type);

    return rr_sv;
}
