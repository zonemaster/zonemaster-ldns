#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "ldns_glue.h"

#define D_STRING(what,where) ldns_rdf2str(ldns_rr_rdf(what,where))
#define D_U8(what,where) ldns_rdf2native_int8(ldns_rr_rdf(what,where))
#define D_U16(what,where) ldns_rdf2native_int16(ldns_rr_rdf(what,where))
#define D_U32(what,where) ldns_rdf2native_int32(ldns_rr_rdf(what,where))

MODULE = NetLDNS        PACKAGE = NetLDNS

PROTOTYPES: ENABLE

NetLDNS
new(class,str)
    char *class;
    char *str;

NetLDNS::Packet
query(obj, dname, rrtype="A", rrclass="IN")
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

SV *
packet_answer(obj)
    NetLDNS::Packet obj;
    PPCODE:
    {
        size_t i,n;
        ldns_rr_list *rrs;

        rrs = ldns_pkt_answer(obj);
        n = ldns_rr_list_rr_count(rrs);

        EXTEND(sp,n);
        for(i = 0; i < n; ++i)
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

SV *
packet_authority(obj)
    NetLDNS::Packet obj;
    PPCODE:
    {
        size_t i,n;
        ldns_rr_list *rrs;

        rrs = ldns_pkt_authority(obj);
        n = ldns_rr_list_rr_count(rrs);

        EXTEND(sp,n);
        for(i = 0; i < n; ++i)
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

SV *
packet_additional(obj)
    NetLDNS::Packet obj;
    PPCODE:
    {
        size_t i,n;
        ldns_rr_list *rrs;

        rrs = ldns_pkt_additional(obj);
        n = ldns_rr_list_rr_count(rrs);

        EXTEND(sp,n);
        for(i = 0; i < n; ++i)
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

SV *
packet_question(obj)
    NetLDNS::Packet obj;
    PPCODE:
    {
        size_t i,n;
        ldns_rr_list *rrs;

        rrs = ldns_pkt_question(obj);
        n = ldns_rr_list_rr_count(rrs);

        EXTEND(sp,n);
        for(i = 0; i < n; ++i)
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

char *
packet_string(obj)
    NetLDNS::Packet obj;
    CODE:
        RETVAL = ldns_pkt2str(obj);
    OUTPUT:
        RETVAL

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


MODULE = NetLDNS        PACKAGE = NetLDNS::RR::MX           PREFIX=rr_mx_

U16
rr_mx_preference(obj)
    NetLDNS::RR::MX obj;
    CODE:
        RETVAL = D_U16(obj, 0);
    OUTPUT:
        RETVAL

char *
rr_mx_exchange(obj)
    NetLDNS::RR::MX obj;
    CODE:
        RETVAL = D_STRING(obj, 1);
    OUTPUT:
        RETVAL

MODULE = NetLDNS        PACKAGE = NetLDNS::RR::A                PREFIX=rr_a_

char *
rr_a_address(obj)
    NetLDNS::RR::A obj;
    CODE:
        ldns_rdf *rdata = ldns_rr_rdf(obj,0);
        uint8_t *p = ldns_rdf_data(rdata);
        char *address;

        Newxz(address,16,char); /* enough for an IPv4 address as text with terminating zero */
        snprintf(address, 16, "%d.%d.%d.%d", p[0], p[1], p[2], p[3]);
        RETVAL = address;
    OUTPUT:
        RETVAL

MODULE = NetLDNS        PACKAGE = NetLDNS::RR::AAAA             PREFIX=rr_aaaa_

char *
rr_aaaa_address(obj)
    NetLDNS::RR::AAAA obj;
    CODE:
        ldns_rdf *rdata = ldns_rr_rdf(obj,0);
        uint8_t *p = ldns_rdf_data(rdata);
        char *address;

        Newxz(address,40,char); /* enough for an IPv6 address as text with terminating zero */
        snprintf(address, 40, "%02x%02x:%02x%02x:%02x%02x:%02x%02x:%02x%02x:%02x%02x:%02x%02x:%02x%02x",
            p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9], p[10], p[11], p[12], p[13], p[14], p[15] );
        RETVAL = address;
    OUTPUT:
        RETVAL

MODULE = NetLDNS        PACKAGE = NetLDNS::RR::SOA              PREFIX=rr_soa_

char *
rr_soa_mname(obj)
    NetLDNS::RR::SOA obj;
    CODE:
        RETVAL = D_STRING(obj,0);
    OUTPUT:
        RETVAL

char *
rr_soa_rname(obj)
    NetLDNS::RR::SOA obj;
    CODE:
        RETVAL = D_STRING(obj,1);
    OUTPUT:
        RETVAL

U32
rr_soa_serial(obj)
    NetLDNS::RR::SOA obj;
    CODE:
        RETVAL = D_U32(obj,2);
    OUTPUT:
        RETVAL

U32
rr_soa_refresh(obj)
    NetLDNS::RR::SOA obj;
    CODE:
        RETVAL = D_U32(obj,3);
    OUTPUT:
        RETVAL

U32
rr_soa_retry(obj)
    NetLDNS::RR::SOA obj;
    CODE:
        RETVAL = D_U32(obj,4);
    OUTPUT:
        RETVAL

U32
rr_soa_expire(obj)
    NetLDNS::RR::SOA obj;
    CODE:
        RETVAL = D_U32(obj,5);
    OUTPUT:
        RETVAL

U32
rr_soa_minimum(obj)
    NetLDNS::RR::SOA obj;
    CODE:
        RETVAL = D_U32(obj,6);
    OUTPUT:
        RETVAL

MODULE = NetLDNS        PACKAGE = NetLDNS::RR::DS               PREFIX=rr_ds_

U16
rr_ds_keytag(obj)
    NetLDNS::RR::DS obj;
    CODE:
        RETVAL = D_U16(obj,0);
    OUTPUT:
        RETVAL

U8
rr_ds_algorithm(obj)
    NetLDNS::RR::DS obj;
    CODE:
        RETVAL = D_U8(obj,1);
    OUTPUT:
        RETVAL

U8
rr_ds_digtype(obj)
    NetLDNS::RR::DS obj;
    CODE:
        RETVAL = D_U8(obj,2);
    OUTPUT:
        RETVAL

SV *
rr_ds_digest(obj)
    NetLDNS::RR::DS obj;
    CODE:
    {
        ldns_rdf *rdf = ldns_rr_rdf(obj,3);
        RETVAL = newSVpvn((char*)ldns_rdf_data(rdf), ldns_rdf_size(rdf));
    }
    OUTPUT:
        RETVAL

char *
rr_ds_hexdigest(obj)
    NetLDNS::RR::DS obj;
    CODE:
        RETVAL = D_STRING(obj,3);
    OUTPUT:
        RETVAL

MODULE = NetLDNS        PACKAGE = NetLDNS::RR::DNSKEY           PREFIX=rr_dnskey_

U16
rr_dnskey_flags(obj)
    NetLDNS::RR::DNSKEY obj;
    CODE:
        RETVAL = D_U16(obj,0);
    OUTPUT:
        RETVAL

U8
rr_dnskey_protocol(obj)
    NetLDNS::RR::DNSKEY obj;
    CODE:
        RETVAL = D_U8(obj,1);
    OUTPUT:
        RETVAL

U8
rr_dnskey_algorithm(obj)
    NetLDNS::RR::DNSKEY obj;
    CODE:
        RETVAL = D_U8(obj,2);
    OUTPUT:
        RETVAL

SV *
rr_dnskey_keydata(obj)
    NetLDNS::RR::DNSKEY obj;
    CODE:
    {
        ldns_rdf *rdf = ldns_rr_rdf(obj,3);
        RETVAL = newSVpvn((char*)ldns_rdf_data(rdf), ldns_rdf_size(rdf));
    }
    OUTPUT:
        RETVAL

MODULE = NetLDNS        PACKAGE = NetLDNS::RR::RRSIG            PREFIX=rr_rrsig_

char *
rr_rrsig_typecovered(obj)
    NetLDNS::RR::RRSIG obj;
    CODE:
        RETVAL = D_STRING(obj,0);
    OUTPUT:
        RETVAL

U8
rr_rrsig_algorithm(obj)
    NetLDNS::RR::RRSIG obj;
    CODE:
        RETVAL = D_U8(obj,1);
    OUTPUT:
        RETVAL

U8
rr_rrsig_labels(obj)
    NetLDNS::RR::RRSIG obj;
    CODE:
        RETVAL = D_U8(obj,2);
    OUTPUT:
        RETVAL

U32
rr_rrsig_origttl(obj)
    NetLDNS::RR::RRSIG obj;
    CODE:
        RETVAL = D_U32(obj,3);
    OUTPUT:
        RETVAL

U32
rr_rrsig_expiration(obj)
    NetLDNS::RR::RRSIG obj;
    CODE:
        RETVAL = D_U32(obj,4);
    OUTPUT:
        RETVAL

U32
rr_rrsig_inception(obj)
    NetLDNS::RR::RRSIG obj;
    CODE:
        RETVAL = D_U32(obj,5);
    OUTPUT:
        RETVAL

U16
rr_rrsig_keytag(obj)
    NetLDNS::RR::RRSIG obj;
    CODE:
        RETVAL = D_U16(obj,6);
    OUTPUT:
        RETVAL

char *
rr_rrsig_signer(obj)
    NetLDNS::RR::RRSIG obj;
    CODE:
        RETVAL = D_STRING(obj,7);
    OUTPUT:
        RETVAL

SV *
rr_rrsig_signature(obj)
    NetLDNS::RR::RRSIG obj;
    CODE:
    {
        ldns_rdf *rdf = ldns_rr_rdf(obj,8);
        RETVAL = newSVpvn((char*)ldns_rdf_data(rdf), ldns_rdf_size(rdf));
    }
    OUTPUT:
        RETVAL

MODULE = NetLDNS        PACKAGE = NetLDNS::RR::NSEC             PREFIX=rr_nsec_

char *
rr_nsec_next(obj)
    NetLDNS::RR::NSEC obj;
    CODE:
        RETVAL = D_STRING(obj,0);
    OUTPUT:
        RETVAL

char *
rr_nsec_typelist(obj)
    NetLDNS::RR::NSEC obj;
    CODE:
        RETVAL = D_STRING(obj,1);
    OUTPUT:
        RETVAL

SV *
rr_nsec_typehref(obj)
    NetLDNS::RR::NSEC obj;
    CODE:
    {
        char *typestring = D_STRING(obj,1);
        size_t pos;
        HV *res = newHV();

        pos = 0;
        while(typestring[pos] != '\0')
        {
            pos++;
            if(typestring[pos] == ' ')
            {
                typestring[pos] = '\0';
                if(hv_store(res,typestring,pos,&PL_sv_yes,0)==NULL)
                {
                    croak("Failed to store to hash");
                }
                typestring += pos+1;
                pos = 0;
            }
        }
        RETVAL = newRV_noinc((SV *)res);
    }
    OUTPUT:
        RETVAL

MODULE = NetLDNS        PACKAGE = NetLDNS::RR::NSEC3            PREFIX=rr_nsec3_
MODULE = NetLDNS        PACKAGE = NetLDNS::RR::NSEC3PARAM       PREFIX=rr_nsec3param_
MODULE = NetLDNS        PACKAGE = NetLDNS::RR::PTR              PREFIX=rr_ptr_

char *
rr_ptr_ptrdname(obj)
    NetLDNS::RR::PTR obj;
    CODE:
        RETVAL = D_STRING(obj,0);
    OUTPUT:
        RETVAL

MODULE = NetLDNS        PACKAGE = NetLDNS::RR::CNAME            PREFIX=rr_cname_

char *
rr_cname_cname(obj)
    NetLDNS::RR::CNAME obj;
    CODE:
        RETVAL = D_STRING(obj,0);
    OUTPUT:
        RETVAL

MODULE = NetLDNS        PACKAGE = NetLDNS::RR::TXT              PREFIX=rr_txt_

char *
rr_txt_txtdata(obj)
    NetLDNS::RR::TXT obj;
    CODE:
        RETVAL = D_STRING(obj,0);
    OUTPUT:
        RETVAL