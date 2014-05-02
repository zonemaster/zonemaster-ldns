#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define NEED_sv_2pv_flags
#define NEED_newRV_noinc
#include "ppport.h"

#include <stdio.h>
#include <unistd.h>
#include <ctype.h>
#include <ldns/ldns.h>

typedef ldns_resolver *Net__LDNS;
typedef ldns_pkt *Net__LDNS__Packet;
typedef ldns_rr_list *Net__LDNS__RRList;
typedef ldns_rr *Net__LDNS__RR;
typedef ldns_rr *Net__LDNS__RR__A;
typedef ldns_rr *Net__LDNS__RR__A6;
typedef ldns_rr *Net__LDNS__RR__AAAA;
typedef ldns_rr *Net__LDNS__RR__AFSDB;
typedef ldns_rr *Net__LDNS__RR__APL;
typedef ldns_rr *Net__LDNS__RR__ATMA;
typedef ldns_rr *Net__LDNS__RR__CAA;
typedef ldns_rr *Net__LDNS__RR__CDS;
typedef ldns_rr *Net__LDNS__RR__CERT;
typedef ldns_rr *Net__LDNS__RR__CNAME;
typedef ldns_rr *Net__LDNS__RR__DHCID;
typedef ldns_rr *Net__LDNS__RR__DLV;
typedef ldns_rr *Net__LDNS__RR__DNAME;
typedef ldns_rr *Net__LDNS__RR__DNSKEY;
typedef ldns_rr *Net__LDNS__RR__DS;
typedef ldns_rr *Net__LDNS__RR__EID;
typedef ldns_rr *Net__LDNS__RR__EUI48;
typedef ldns_rr *Net__LDNS__RR__EUI64;
typedef ldns_rr *Net__LDNS__RR__GID;
typedef ldns_rr *Net__LDNS__RR__GPOS;
typedef ldns_rr *Net__LDNS__RR__HINFO;
typedef ldns_rr *Net__LDNS__RR__HIP;
typedef ldns_rr *Net__LDNS__RR__IPSECKEY;
typedef ldns_rr *Net__LDNS__RR__ISDN;
typedef ldns_rr *Net__LDNS__RR__KEY;
typedef ldns_rr *Net__LDNS__RR__KX;
typedef ldns_rr *Net__LDNS__RR__L32;
typedef ldns_rr *Net__LDNS__RR__L64;
typedef ldns_rr *Net__LDNS__RR__LOC;
typedef ldns_rr *Net__LDNS__RR__LP;
typedef ldns_rr *Net__LDNS__RR__MAILA;
typedef ldns_rr *Net__LDNS__RR__MAILB;
typedef ldns_rr *Net__LDNS__RR__MB;
typedef ldns_rr *Net__LDNS__RR__MD;
typedef ldns_rr *Net__LDNS__RR__MF;
typedef ldns_rr *Net__LDNS__RR__MG;
typedef ldns_rr *Net__LDNS__RR__MINFO;
typedef ldns_rr *Net__LDNS__RR__MR;
typedef ldns_rr *Net__LDNS__RR__MX;
typedef ldns_rr *Net__LDNS__RR__NAPTR;
typedef ldns_rr *Net__LDNS__RR__NID;
typedef ldns_rr *Net__LDNS__RR__NIMLOC;
typedef ldns_rr *Net__LDNS__RR__NINFO;
typedef ldns_rr *Net__LDNS__RR__NS;
typedef ldns_rr *Net__LDNS__RR__NSAP;
typedef ldns_rr *Net__LDNS__RR__NSEC;
typedef ldns_rr *Net__LDNS__RR__NSEC3;
typedef ldns_rr *Net__LDNS__RR__NSEC3PARAM;
typedef ldns_rr *Net__LDNS__RR__NULL;
typedef ldns_rr *Net__LDNS__RR__NXT;
typedef ldns_rr *Net__LDNS__RR__PTR;
typedef ldns_rr *Net__LDNS__RR__PX;
typedef ldns_rr *Net__LDNS__RR__RKEY;
typedef ldns_rr *Net__LDNS__RR__RP;
typedef ldns_rr *Net__LDNS__RR__RRSIG;
typedef ldns_rr *Net__LDNS__RR__RT;
typedef ldns_rr *Net__LDNS__RR__SIG;
typedef ldns_rr *Net__LDNS__RR__SINK;
typedef ldns_rr *Net__LDNS__RR__SOA;
typedef ldns_rr *Net__LDNS__RR__SPF;
typedef ldns_rr *Net__LDNS__RR__SRV;
typedef ldns_rr *Net__LDNS__RR__SSHFP;
typedef ldns_rr *Net__LDNS__RR__TA;
typedef ldns_rr *Net__LDNS__RR__TALINK;
typedef ldns_rr *Net__LDNS__RR__TKEY;
typedef ldns_rr *Net__LDNS__RR__TLSA;
typedef ldns_rr *Net__LDNS__RR__TXT;
typedef ldns_rr *Net__LDNS__RR__TYPE;
typedef ldns_rr *Net__LDNS__RR__UID;
typedef ldns_rr *Net__LDNS__RR__UINFO;
typedef ldns_rr *Net__LDNS__RR__UNSPEC;
typedef ldns_rr *Net__LDNS__RR__URI;
typedef ldns_rr *Net__LDNS__RR__WKS;
typedef ldns_rr *Net__LDNS__RR__X25;

#define D_STRING(what,where) ldns_rdf2str(ldns_rr_rdf(what,where))
#define D_U8(what,where) ldns_rdf2native_int8(ldns_rr_rdf(what,where))
#define D_U16(what,where) ldns_rdf2native_int16(ldns_rr_rdf(what,where))
#define D_U32(what,where) ldns_rdf2native_int32(ldns_rr_rdf(what,where))

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

MODULE = Net::LDNS        PACKAGE = Net::LDNS

PROTOTYPES: ENABLE

const char *
lib_version()
    CODE:
        RETVAL = ldns_version();
    OUTPUT:
        RETVAL

Net::LDNS
new(class, ...)
    char *class;
    CODE:
    {
        int i;

        if (items == 1 ) { /* Called without arguments, use resolv.conf */
            ldns_resolver_new_frm_file(&RETVAL,NULL);
        }
        else {
            RETVAL = ldns_resolver_new();
            for (i=1;i<items;i++)
            {
                ldns_status s;
                ldns_rdf *addr;

                if ( !SvOK(ST(i)) || !SvPOK(ST(i)) ) {
                    continue; /* Skip non-strings */
                }

                addr = ldns_rdf_new_frm_str(LDNS_RDF_TYPE_A, SvPV_nolen(ST(i)));
                if ( addr == NULL) {
                    addr = ldns_rdf_new_frm_str(LDNS_RDF_TYPE_AAAA, SvPV_nolen(ST(i)));
                }
                if ( addr == NULL ) {
                    croak("Failed to parse IP address: %s", SvPV_nolen(ST(i)));
                }
                s = ldns_resolver_push_nameserver(RETVAL, addr);
                if(s != LDNS_STATUS_OK)
                {
                    croak("Adding nameserver failed: %s", ldns_get_errorstr_by_id(s));
                }
            }
        }
    }
    OUTPUT:
        RETVAL

Net::LDNS::Packet
query(obj, dname, rrtype="A", rrclass="IN")
    Net::LDNS obj;
    char *dname;
    char *rrtype;
    char *rrclass;
    CODE:
    {
        ldns_rdf *domain;
        ldns_rr_type t;
        ldns_rr_class c;
        ldns_status status;
        ldns_pkt *pkt;

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
        if(domain==NULL)
        {
            croak("Invalid domain name: %s", dname);
        }
        status = ldns_resolver_send(&pkt, obj, domain, t, c, LDNS_RD);
        if ( status != LDNS_STATUS_OK) {
            croak("%s", ldns_get_errorstr_by_id(status));
            RETVAL = NULL;
        }
        RETVAL = ldns_pkt_clone(pkt);
        ldns_pkt_set_timestamp(RETVAL, ldns_pkt_timestamp(pkt));
    }
    OUTPUT:
        RETVAL

bool
recurse(obj,...)
    Net::LDNS obj;
    CODE:
        if(items>1) {
            ldns_resolver_set_recursive(obj, SvIV(ST(1)));
        }
        RETVAL = ldns_resolver_recursive(obj);
    OUTPUT:
        RETVAL

bool
debug(obj,...)
    Net::LDNS obj;
    CODE:
        if ( items > 1 ) {
            ldns_resolver_set_debug(obj, SvIV(ST(1)));
        }
        RETVAL = ldns_resolver_debug(obj);
    OUTPUT:
        RETVAL

bool
dnssec(obj,...)
    Net::LDNS obj;
    CODE:
        if ( items > 1 ) {
            ldns_resolver_set_dnssec(obj, SvIV(ST(1)));
        }
        RETVAL = ldns_resolver_dnssec(obj);
    OUTPUT:
        RETVAL

bool
usevc(obj,...)
    Net::LDNS obj;
    CODE:
        if ( items > 1 ) {
            ldns_resolver_set_usevc(obj, SvIV(ST(1)));
        }
        RETVAL = ldns_resolver_usevc(obj);
    OUTPUT:
        RETVAL

bool
igntc(obj,...)
    Net::LDNS obj;
    CODE:
        if ( items > 1 ) {
            ldns_resolver_set_igntc(obj, SvIV(ST(1)));
        }
        RETVAL = ldns_resolver_igntc(obj);
    OUTPUT:
        RETVAL

U8
retry(obj,...)
    Net::LDNS obj;
    CODE:
        if ( items > 1 ) {
            ldns_resolver_set_retry(obj, SvIV(ST(1)));
        }
        RETVAL = ldns_resolver_retry(obj);
    OUTPUT:
        RETVAL

U8
retrans(obj,...)
    Net::LDNS obj;
    CODE:
        if ( items > 1 ) {
            ldns_resolver_set_retrans(obj, SvIV(ST(1)));
        }
        RETVAL = ldns_resolver_retrans(obj);
    OUTPUT:
        RETVAL

SV *
name2addr(obj,name)
    Net::LDNS obj;
    const char *name;
    PPCODE:
    {
        ldns_rr_list *addrs;
        ldns_rdf *dname = ldns_rdf_new_frm_str(LDNS_RDF_TYPE_DNAME, name);
        size_t n, i;
        I32 context;

        context = GIMME_V;

        if(context == G_VOID)
        {
            XSRETURN_NO;
        }

        if(dname==NULL)
        {
            croak("Name error for '%s'", name);
        }

        addrs = ldns_get_rr_list_addr_by_name(obj,dname,LDNS_RR_CLASS_IN,0);
        n = ldns_rr_list_rr_count(addrs);

        if (context == G_SCALAR)
        {
            XSRETURN_IV(n);
        }
        else
        {
            for(i = 0; i < n; ++i)
            {
                ldns_rr *rr = ldns_rr_list_rr(addrs,i);
                ldns_rdf *addr_rdf = ldns_rr_a_address(rr);
                char *addr_str = ldns_rdf2str(addr_rdf);

                SV* sv = newSVpv(addr_str,0);
                mXPUSHs(sv);
                free(addr_str);
            }
        }
    }

SV *
addr2name(obj,addr_in)
    Net::LDNS obj;
    const char *addr_in;
    PPCODE:
    {
        ldns_rr_list *names;
        ldns_rdf *addr_rdf;
        size_t n, i;
        I32 context;

        context = GIMME_V;

        if(context == G_VOID)
        {
            XSRETURN_NO;
        }

        addr_rdf = ldns_rdf_new_frm_str(LDNS_RDF_TYPE_A, addr_in);
        if(addr_rdf==NULL)
        {
            addr_rdf = ldns_rdf_new_frm_str(LDNS_RDF_TYPE_AAAA, addr_in);
        }
        if(addr_rdf==NULL)
        {
            croak("Failed to parse address: %s", addr_in);
        }

        names = ldns_get_rr_list_name_by_addr(obj,addr_rdf,LDNS_RR_CLASS_IN,0);
        n = ldns_rr_list_rr_count(names);

        if (context == G_SCALAR)
        {
            XSRETURN_IV(n);
        }
        else
        {
            for(i = 0; i < n; ++i)
            {
                ldns_rr *rr = ldns_rr_list_rr(names,i);
                ldns_rdf *name_rdf = ldns_rr_rdf(rr,0);
                char *name_str = ldns_rdf2str(name_rdf);

                SV* sv = newSVpv(name_str,0);
                mXPUSHs(sv);
                free(name_str);
            }
        }
    }

bool
axfr_start(obj,dname,class="IN")
    Net::LDNS obj;
    const char *dname;
    const char *class;
    CODE:
    {
        ldns_rdf *domain = ldns_rdf_new_frm_str(LDNS_RDF_TYPE_DNAME, dname);
        ldns_rr_class cl = ldns_get_rr_class_by_name(class);
        ldns_status s;

        if(domain==NULL)
        {
            croak("Name error for '%s", dname);
        }

        if(!cl)
        {
            croak("Unknown RR class: %s", class);
        }

        s = ldns_axfr_start(obj, domain, cl);

        RETVAL = (s==LDNS_STATUS_OK);
    }
    OUTPUT:
        RETVAL

SV *
axfr_next(obj)
    Net::LDNS obj;
    CODE:
    {
        ldns_rr *rr;

        /* ldns unfortunately prints to standard error, so close it while we call them */
        int err_fd = fileno(stderr);            /* Remember fd for stderr */
        int save_fd = dup(err_fd);              /* Copy open fd for stderr */
        int tmp_fd;

        fflush(stderr);                         /* Print anything waiting */
        tmp_fd = open("/dev/null",O_RDWR);    /* Open something to allocate the now-free fd stderr used */
        dup2(tmp_fd,err_fd);
        rr = ldns_axfr_next(obj);               /* Shut up */
        close(tmp_fd);                          /* Close the placeholder */
        fflush(stderr);                         /* Flush anything ldns buffered */
        dup2(save_fd,err_fd);                   /* And copy the open stderr back to where it should be */

        if(rr==NULL)
        {
            croak("AXFR error");
        }

        RETVAL = rr2sv(rr);
    }
    OUTPUT:
        RETVAL

bool
axfr_complete(obj)
    Net::LDNS obj;
    CODE:
        RETVAL = ldns_axfr_complete(obj);
    OUTPUT:
        RETVAL

Net::LDNS::Packet
axfr_last_packet(obj)
    Net::LDNS obj;
    CODE:
        RETVAL = ldns_axfr_last_pkt(obj);
    OUTPUT:
        RETVAL

void
DESTROY(obj)
    Net::LDNS obj;
    CODE:
        ldns_resolver_free(obj);

MODULE = Net::LDNS        PACKAGE = Net::LDNS::Packet           PREFIX=packet_

Net::LDNS::Packet
packet_new(objclass,name,type="A",class="IN")
    char *objclass;
    char *name;
    char *type;
    char *class;
    CODE:
    {
        ldns_rdf *rr_name;
        ldns_rr_type rr_type;
        ldns_rr_class rr_class;
        
        rr_type = ldns_get_rr_type_by_name(type);
        if(!rr_type)
        {
            croak("Unknown RR type: %s", type);
        }
        
        rr_class = ldns_get_rr_class_by_name(class);
        if(!rr_class)
        {
            croak("Unknown RR class: %s", class);
        }
        
        rr_name = ldns_rdf_new_frm_str(LDNS_RDF_TYPE_DNAME, name);
        if(rr_name == NULL)
        {
            croak("Name error for '%s'", name);
        }
        
        RETVAL = ldns_pkt_query_new(rr_name, rr_type, rr_class,0);
    }
    OUTPUT:
        RETVAL

char *
packet_rcode(obj)
    Net::LDNS::Packet obj;
    CODE:
        RETVAL = ldns_pkt_rcode2str(ldns_pkt_get_rcode(obj));
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);

char *
packet_opcode(obj)
    Net::LDNS::Packet obj;
    CODE:
        RETVAL = ldns_pkt_opcode2str(ldns_pkt_get_opcode(obj));
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);

U16
packet_id(obj)
    Net::LDNS::Packet obj;
    CODE:
        RETVAL = ldns_pkt_id(obj);
    OUTPUT:
        RETVAL

bool
packet_qr(obj,...)
    Net::LDNS::Packet obj;
    CODE:
        if ( items > 1 ) {
            ldns_pkt_set_qr(obj, SvIV(ST(1)));
        }
        RETVAL = ldns_pkt_qr(obj);
    OUTPUT:
        RETVAL

bool
packet_aa(obj,...)
    Net::LDNS::Packet obj;
    CODE:
        if ( items > 1 ) {
            ldns_pkt_set_aa(obj, SvIV(ST(1)));
        }
        RETVAL = ldns_pkt_aa(obj);
    OUTPUT:
        RETVAL

bool
packet_tc(obj,...)
    Net::LDNS::Packet obj;
    CODE:
        if ( items > 1 ) {
            ldns_pkt_set_tc(obj, SvIV(ST(1)));
        }
        RETVAL = ldns_pkt_tc(obj);
    OUTPUT:
        RETVAL

bool
packet_rd(obj,...)
    Net::LDNS::Packet obj;
    CODE:
        if ( items > 1 ) {
            ldns_pkt_set_rd(obj, SvIV(ST(1)));
        }
        RETVAL = ldns_pkt_rd(obj);
    OUTPUT:
        RETVAL

bool
packet_cd(obj,...)
    Net::LDNS::Packet obj;
    CODE:
        if ( items > 1 ) {
            ldns_pkt_set_cd(obj, SvIV(ST(1)));
        }
        RETVAL = ldns_pkt_cd(obj);
    OUTPUT:
        RETVAL

bool
packet_ra(obj,...)
    Net::LDNS::Packet obj;
    CODE:
        if ( items > 1 ) {
            ldns_pkt_set_ra(obj, SvIV(ST(1)));
        }
        RETVAL = ldns_pkt_ra(obj);
    OUTPUT:
        RETVAL

bool
packet_ad(obj,...)
    Net::LDNS::Packet obj;
    CODE:
        if ( items > 1 ) {
            ldns_pkt_set_ad(obj, SvIV(ST(1)));
        }
        RETVAL = ldns_pkt_ad(obj);
    OUTPUT:
        RETVAL

bool
packet_do(obj,...)
    Net::LDNS::Packet obj;
    CODE:
        if ( items > 1 ) {
            ldns_pkt_set_edns_do(obj, SvIV(ST(1)));
        }
        RETVAL = ldns_pkt_edns_do(obj);
    OUTPUT:
        RETVAL

size_t
packet_size(obj)
    Net::LDNS::Packet obj;
    CODE:
        RETVAL = ldns_pkt_size(obj);
    OUTPUT:
        RETVAL

U32
packet_querytime(obj)
    Net::LDNS::Packet obj;
    CODE:
        RETVAL = ldns_pkt_querytime(obj);
    OUTPUT:
        RETVAL

char *
packet_answerfrom(obj,...)
    Net::LDNS::Packet obj;
    CODE:
        if(items >= 2)
        {
            if(SvOK(ST(1)) && SvPOK(ST(1)))
            {
                ldns_rdf *address;
                
                address = ldns_rdf_new_frm_str(LDNS_RDF_TYPE_A, SvPV_nolen(ST(1)));
                if(address == NULL)
                {
                    address = ldns_rdf_new_frm_str(LDNS_RDF_TYPE_AAAA, SvPV_nolen(ST(1)));
                }
                if(address == NULL)
                {
                    croak("Failed to parse IP address: %s", SvPV_nolen(ST(1)));
                }
                
                ldns_pkt_set_answerfrom(obj, address);
            }
        }
        RETVAL = ldns_rdf2str(ldns_pkt_answerfrom(obj));
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);

double
packet_timestamp(obj,...)
    Net::LDNS::Packet obj;
    CODE:
        if(items >= 2)
        {
            struct timeval tn;
            double dec_part, int_part;
            
            dec_part = modf(SvNV(ST(1)), &int_part);
            tn.tv_sec  = int_part;
            tn.tv_usec = 1000000*dec_part;
            ldns_pkt_set_timestamp(obj,tn);
        }
        struct timeval t = ldns_pkt_timestamp(obj);
        RETVAL = (double)t.tv_sec;
        RETVAL += ((double)t.tv_usec)/1000000;
    OUTPUT:
        RETVAL

SV *
packet_answer(obj)
    Net::LDNS::Packet obj;
    PPCODE:
    {
        size_t i,n;
        ldns_rr_list *rrs;
        I32 context = GIMME_V;

        if (context == G_VOID)
        {
            return;
        }

        rrs = ldns_pkt_answer(obj);
        n = ldns_rr_list_rr_count(rrs);

        if (context == G_SCALAR)
        {
            XSRETURN_IV(n);
        }

        for(i = 0; i < n; ++i)
        {
            mXPUSHs(rr2sv(ldns_rr_clone(ldns_rr_list_rr(rrs,i))));
        }
    }

SV *
packet_authority(obj)
    Net::LDNS::Packet obj;
    PPCODE:
    {
        size_t i,n;
        ldns_rr_list *rrs;
        I32 context = GIMME_V;

        if (context == G_VOID)
        {
            return;
        }

        rrs = ldns_pkt_authority(obj);
        n = ldns_rr_list_rr_count(rrs);

        if (context == G_SCALAR)
        {
            XSRETURN_IV(n);
        }

        for(i = 0; i < n; ++i)
        {
            mXPUSHs(rr2sv(ldns_rr_clone(ldns_rr_list_rr(rrs,i))));
        }
    }

SV *
packet_additional(obj)
    Net::LDNS::Packet obj;
    PPCODE:
    {
        size_t i,n;
        ldns_rr_list *rrs;
        I32 context = GIMME_V;

        if (context == G_VOID)
        {
            return;
        }

        rrs = ldns_pkt_additional(obj);
        n = ldns_rr_list_rr_count(rrs);

        if (context == G_SCALAR)
        {
            XSRETURN_IV(n);
        }

        for(i = 0; i < n; ++i)
        {
            mXPUSHs(rr2sv(ldns_rr_clone(ldns_rr_list_rr(rrs,i))));
        }
    }

SV *
packet_question(obj)
    Net::LDNS::Packet obj;
    PPCODE:
    {
        size_t i,n;
        ldns_rr_list *rrs;
        I32 context = GIMME_V;

        if (context == G_VOID)
        {
            return;
        }

        rrs = ldns_pkt_question(obj);
        n = ldns_rr_list_rr_count(rrs);

        if (context == G_SCALAR)
        {
            XSRETURN_IV(n);
        }

        for(i = 0; i < n; ++i)
        {
            mXPUSHs(rr2sv(ldns_rr_clone(ldns_rr_list_rr(rrs,i))));
        }
    }

bool
packet_unique_push(obj,section,rr)
    Net::LDNS::Packet obj;
    char *section;
    Net::LDNS::RR rr;
    CODE:
    {
        ldns_pkt_section sec;
        char lbuf[21];
        char *p;
        
        p = lbuf;
        strncpy(lbuf, section, 20);
        for(; *p; p++) *p = tolower(*p);

        if(strncmp(lbuf, "answer", 6)==0)
        {
            sec = LDNS_SECTION_ANSWER;
        }
        else if(strncmp(lbuf, "additional", 10)==0)
        {
            sec = LDNS_SECTION_ADDITIONAL;
        }
        else if(strncmp(lbuf, "authority", 9)==0)
        {
            sec = LDNS_SECTION_AUTHORITY;
        }
        else if(strncmp(lbuf, "question", 8)==0)
        {
            sec = LDNS_SECTION_QUESTION;
        }
        else
        {
            croak("Unknown section: %s", section);
        }
        
        RETVAL = ldns_pkt_safe_push_rr(obj, sec, ldns_rr_clone(rr));
    }
    OUTPUT:
        RETVAL

Net::LDNS::RRList
packet_all(obj)
    Net::LDNS::Packet obj;
    CODE:
        RETVAL = ldns_pkt_all_noquestion(obj);
    OUTPUT:
        RETVAL

char *
packet_string(obj)
    Net::LDNS::Packet obj;
    CODE:
        RETVAL = ldns_pkt2str(obj);
        RETVAL[strlen(RETVAL)-1] = '\0';
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);

SV *
packet_wireformat(obj)
    Net::LDNS::Packet obj;
    CODE:
    {
        size_t sz;
        uint8_t *buf;
        ldns_status status;

        status = ldns_pkt2wire(&buf, obj, &sz);
        if(status != LDNS_STATUS_OK)
        {
            croak("Failed to produce wire format: %s",  ldns_get_errorstr_by_id(status));
        }
        else
        {
            RETVAL = newSVpvn((const char *)buf,sz);
            free(buf);
        }
    }
    OUTPUT:
        RETVAL

Net::LDNS::Packet
packet_new_from_wireformat(class,buf)
    char *class;
    SV *buf;
    CODE:
    {
        Net__LDNS__Packet pkt;
        ldns_status status;

        status = ldns_wire2pkt(&pkt, (const uint8_t *)SvPV_nolen(buf), SvCUR(buf));
        if(status != LDNS_STATUS_OK)
        {
            croak("Failed to parse wire format: %s",  ldns_get_errorstr_by_id(status));
        }
        else
        {
            RETVAL = pkt;
        }
    }
    OUTPUT:
        RETVAL

U16
packet_edns_size(obj,...)
    Net::LDNS::Packet obj;
    CODE:
        if(items>=2)
        {
            ldns_pkt_set_edns_udp_size(obj, (U16)SvIV(ST(1)));
        }
        RETVAL = ldns_pkt_edns_udp_size(obj);
    OUTPUT:
        RETVAL

U8
packet_edns_rcode(obj,...)
    Net::LDNS::Packet obj;
    CODE:
        if(items>=2)
        {
            ldns_pkt_set_edns_extended_rcode(obj, (U8)SvIV(ST(1)));
        }
        RETVAL = ldns_pkt_edns_extended_rcode(obj);
    OUTPUT:
        RETVAL

SV *
packet_type(obj)
    Net::LDNS::Packet obj;
    CODE:
        ldns_pkt_type type = ldns_pkt_reply_type(obj);
        switch (type){
            case LDNS_PACKET_QUESTION:
                RETVAL = newSVpvs_share("question");
                break;

            case LDNS_PACKET_REFERRAL:
                RETVAL = newSVpvs_share("referral");
                break;

            case LDNS_PACKET_ANSWER:
                RETVAL = newSVpvs_share("answer");
                break;

            case LDNS_PACKET_NXDOMAIN:
                RETVAL = newSVpvs_share("nxdomain");
                break;

            case LDNS_PACKET_NODATA:
                RETVAL = newSVpvs_share("nodata");
                break;

            case LDNS_PACKET_UNKNOWN:
                RETVAL = newSVpvs_share("unknown");
                break;

            default:
                croak("Packet type is not even unknown");
        }
    OUTPUT:
        RETVAL

void
packet_DESTROY(obj)
    Net::LDNS::Packet obj;
    CODE:
        ldns_pkt_free(obj);

MODULE = Net::LDNS        PACKAGE = Net::LDNS::RRList           PREFIX=rrlist_

size_t
rrlist_count(obj)
    Net::LDNS::RRList obj;
    CODE:
        RETVAL = ldns_rr_list_rr_count(obj);
    OUTPUT:
        RETVAL

SV *
rrlist_pop(obj)
    Net::LDNS::RRList obj;
    CODE:
        ldns_rr *rr = ldns_rr_list_pop_rr(obj);
        if(rr==NULL)
        {
            RETVAL = &PL_sv_no;
        }
        else
        {
            RETVAL = rr2sv(rr);
        }
    OUTPUT:
        RETVAL

bool
rrlist_push(obj,rr)
    Net::LDNS::RRList obj;
    Net::LDNS::RR rr;
    CODE:
        RETVAL = ldns_rr_list_push_rr(obj,ldns_rr_clone(rr));
    OUTPUT:
        RETVAL

bool
rrlist_is_rrset(obj)
    Net::LDNS::RRList obj;
    CODE:
        RETVAL = ldns_is_rrset(obj);
    OUTPUT:
        RETVAL

void
rrlist_DESTROY(obj)
    Net::LDNS::RRList obj;
    CODE:
        ldns_rr_list_deep_free(obj);

MODULE = Net::LDNS        PACKAGE = Net::LDNS::RR           PREFIX=rr_

SV *
rr_new_from_string(class,str)
    char *class;
    char *str;
    PPCODE:
        ldns_status s;
        ldns_rr *rr;
        char rrclass[40];
        char *rrtype;
        SV* rr_sv;

        s = ldns_rr_new_frm_str(&rr, str, 0, NULL, NULL);
        if(s != LDNS_STATUS_OK)
        {
            croak("Failed to build RR: %s", ldns_get_errorstr_by_id(s));
        }
        rrtype = ldns_rr_type2str(ldns_rr_get_type(rr));
        snprintf(rrclass, 39, "Net::LDNS::RR::%s", rrtype);
        free(rrtype);
        rr_sv = sv_newmortal();
        sv_setref_pv(rr_sv, rrclass, rr);
        PUSHs(rr_sv);

char *
rr_owner(obj)
    Net::LDNS::RR obj;
    CODE:
        RETVAL = ldns_rdf2str(ldns_rr_owner(obj));
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);

U32
rr_ttl(obj)
    Net::LDNS::RR obj;
    CODE:
        RETVAL = ldns_rr_ttl(obj);
    OUTPUT:
        RETVAL

char *
rr_type(obj)
    Net::LDNS::RR obj;
    CODE:
        RETVAL = ldns_rr_type2str(ldns_rr_get_type(obj));
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);

char *
rr_class(obj)
    Net::LDNS::RR obj;
    CODE:
        RETVAL = ldns_rr_class2str(ldns_rr_get_class(obj));
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);

char *
rr_string(obj)
    Net::LDNS::RR obj;
    CODE:
        RETVAL = ldns_rr2str(obj);
        RETVAL[strlen(RETVAL)-1] = '\0';
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);

I32
rr_compare(obj1,obj2)
    Net::LDNS::RR obj1;
    Net::LDNS::RR obj2;
    CODE:
        RETVAL = ldns_rr_compare(obj1,obj2);
    OUTPUT:
        RETVAL

size_t
rr_rd_count(obj)
    Net::LDNS::RR obj;
    CODE:
        RETVAL = ldns_rr_rd_count(obj);
    OUTPUT:
        RETVAL

void
rr_DESTROY(obj)
    Net::LDNS::RR obj;
    CODE:
        ldns_rr_free(obj);



MODULE = Net::LDNS        PACKAGE = Net::LDNS::RR::NS           PREFIX=rr_ns_

char *
rr_ns_nsdname(obj)
    Net::LDNS::RR::NS obj;
    CODE:
        RETVAL = ldns_rdf2str(ldns_rr_rdf(obj, 0));
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);


MODULE = Net::LDNS        PACKAGE = Net::LDNS::RR::MX           PREFIX=rr_mx_

U16
rr_mx_preference(obj)
    Net::LDNS::RR::MX obj;
    CODE:
        RETVAL = D_U16(obj, 0);
    OUTPUT:
        RETVAL

char *
rr_mx_exchange(obj)
    Net::LDNS::RR::MX obj;
    CODE:
        RETVAL = D_STRING(obj, 1);
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);


MODULE = Net::LDNS        PACKAGE = Net::LDNS::RR::A                PREFIX=rr_a_

char *
rr_a_address(obj)
    Net::LDNS::RR::A obj;
    CODE:
        RETVAL = D_STRING(obj,0);
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);


MODULE = Net::LDNS        PACKAGE = Net::LDNS::RR::AAAA             PREFIX=rr_aaaa_

char *
rr_aaaa_address(obj)
    Net::LDNS::RR::AAAA obj;
    CODE:
        RETVAL = D_STRING(obj,0);
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);


MODULE = Net::LDNS        PACKAGE = Net::LDNS::RR::SOA              PREFIX=rr_soa_

char *
rr_soa_mname(obj)
    Net::LDNS::RR::SOA obj;
    CODE:
        RETVAL = D_STRING(obj,0);
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);

char *
rr_soa_rname(obj)
    Net::LDNS::RR::SOA obj;
    CODE:
        RETVAL = D_STRING(obj,1);
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);

U32
rr_soa_serial(obj)
    Net::LDNS::RR::SOA obj;
    CODE:
        RETVAL = D_U32(obj,2);
    OUTPUT:
        RETVAL

U32
rr_soa_refresh(obj)
    Net::LDNS::RR::SOA obj;
    CODE:
        RETVAL = D_U32(obj,3);
    OUTPUT:
        RETVAL

U32
rr_soa_retry(obj)
    Net::LDNS::RR::SOA obj;
    CODE:
        RETVAL = D_U32(obj,4);
    OUTPUT:
        RETVAL

U32
rr_soa_expire(obj)
    Net::LDNS::RR::SOA obj;
    CODE:
        RETVAL = D_U32(obj,5);
    OUTPUT:
        RETVAL

U32
rr_soa_minimum(obj)
    Net::LDNS::RR::SOA obj;
    CODE:
        RETVAL = D_U32(obj,6);
    OUTPUT:
        RETVAL


MODULE = Net::LDNS        PACKAGE = Net::LDNS::RR::DS               PREFIX=rr_ds_

U16
rr_ds_keytag(obj)
    Net::LDNS::RR::DS obj;
    CODE:
        RETVAL = D_U16(obj,0);
    OUTPUT:
        RETVAL

U8
rr_ds_algorithm(obj)
    Net::LDNS::RR::DS obj;
    CODE:
        RETVAL = D_U8(obj,1);
    OUTPUT:
        RETVAL

U8
rr_ds_digtype(obj)
    Net::LDNS::RR::DS obj;
    CODE:
        RETVAL = D_U8(obj,2);
    OUTPUT:
        RETVAL

SV *
rr_ds_digest(obj)
    Net::LDNS::RR::DS obj;
    CODE:
    {
        ldns_rdf *rdf = ldns_rr_rdf(obj,3);
        RETVAL = newSVpvn((char*)ldns_rdf_data(rdf), ldns_rdf_size(rdf));
    }
    OUTPUT:
        RETVAL

char *
rr_ds_hexdigest(obj)
    Net::LDNS::RR::DS obj;
    CODE:
        RETVAL = D_STRING(obj,3);
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);


bool
rr_ds_verify(obj,other)
    Net::LDNS::RR::DS obj;
    Net::LDNS::RR other;
    CODE:
        RETVAL = ldns_rr_compare_ds(obj, other);
    OUTPUT:
        RETVAL

MODULE = Net::LDNS        PACKAGE = Net::LDNS::RR::DNSKEY           PREFIX=rr_dnskey_

U32
rr_dnskey_keysize(obj)
    Net::LDNS::RR::DNSKEY obj;
    CODE:
    {
        U8 algorithm = D_U8(obj,2);
        ldns_rdf *rdf = ldns_rr_rdf(obj,3);
        uint8_t *data = ldns_rdf_data(rdf);
        size_t total = ldns_rdf_size(rdf);

        /* RSA variants */
        if(algorithm==1||algorithm==5||algorithm==7||algorithm==8||algorithm==10)
        {
            size_t ex_len;
    
            if(data[0] == 0)
            {
                ex_len = 3+(U16)data[1];
            }
            else
            {
                ex_len = 1+(U8)data[0];
            }
            RETVAL = 8*(total-ex_len);
        }
        /* DSA variants */
        else if(algorithm==3||algorithm==6)
        {
            RETVAL = (U8)data[0]; /* First octet is T value */
        }
        /* Diffie-Hellman */
        else if(algorithm==2)
        {
            RETVAL = (U16)data[4];
        }
        /* No idea what this is */
        else
        {
            RETVAL = 0;
        }
    }
    OUTPUT:
        RETVAL

U16
rr_dnskey_flags(obj)
    Net::LDNS::RR::DNSKEY obj;
    CODE:
        RETVAL = D_U16(obj,0);
    OUTPUT:
        RETVAL

U8
rr_dnskey_protocol(obj)
    Net::LDNS::RR::DNSKEY obj;
    CODE:
        RETVAL = D_U8(obj,1);
    OUTPUT:
        RETVAL

U8
rr_dnskey_algorithm(obj)
    Net::LDNS::RR::DNSKEY obj;
    CODE:
        RETVAL = D_U8(obj,2);
    OUTPUT:
        RETVAL

SV *
rr_dnskey_keydata(obj)
    Net::LDNS::RR::DNSKEY obj;
    CODE:
    {
        ldns_rdf *rdf = ldns_rr_rdf(obj,3);
        RETVAL = newSVpvn((char*)ldns_rdf_data(rdf), ldns_rdf_size(rdf));
    }
    OUTPUT:
        RETVAL

U16
rr_dnskey_keytag(obj)
    Net::LDNS::RR::DNSKEY obj;
    CODE:
        RETVAL = ldns_calc_keytag(obj);
    OUTPUT:
        RETVAL

Net::LDNS::RR::DS
rr_dnskey_ds(obj, hash)
    Net::LDNS::RR::DNSKEY obj;
    const char *hash;
    CODE:
    {
        char lbuf[21];
        char *p;
        ldns_hash htype;
        
        p = lbuf;
        strncpy(lbuf, hash, 20);
        for(; *p; p++) *p = tolower(*p);
        
        if(strEQ(lbuf,"sha1"))
        {
            htype = LDNS_SHA1;
        }
        else if(strEQ(lbuf, "sha256"))
        {
            htype = LDNS_SHA256;
        }
        else if(strEQ(lbuf, "sha384"))
        {
            htype = LDNS_SHA384;
        }
        else if(strEQ(lbuf,"gost"))
        {
            htype = LDNS_HASH_GOST;
        }
        else
        {
            croak("Unknown hash type: %s", hash);
        }
        
        RETVAL = ldns_key_rr2ds(obj,htype);
    }
    OUTPUT:
        RETVAL

MODULE = Net::LDNS        PACKAGE = Net::LDNS::RR::RRSIG            PREFIX=rr_rrsig_

char *
rr_rrsig_typecovered(obj)
    Net::LDNS::RR::RRSIG obj;
    CODE:
        RETVAL = D_STRING(obj,0);
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);

U8
rr_rrsig_algorithm(obj)
    Net::LDNS::RR::RRSIG obj;
    CODE:
        RETVAL = D_U8(obj,1);
    OUTPUT:
        RETVAL

U8
rr_rrsig_labels(obj)
    Net::LDNS::RR::RRSIG obj;
    CODE:
        RETVAL = D_U8(obj,2);
    OUTPUT:
        RETVAL

U32
rr_rrsig_origttl(obj)
    Net::LDNS::RR::RRSIG obj;
    CODE:
        RETVAL = D_U32(obj,3);
    OUTPUT:
        RETVAL

U32
rr_rrsig_expiration(obj)
    Net::LDNS::RR::RRSIG obj;
    CODE:
        RETVAL = D_U32(obj,4);
    OUTPUT:
        RETVAL

U32
rr_rrsig_inception(obj)
    Net::LDNS::RR::RRSIG obj;
    CODE:
        RETVAL = D_U32(obj,5);
    OUTPUT:
        RETVAL

U16
rr_rrsig_keytag(obj)
    Net::LDNS::RR::RRSIG obj;
    CODE:
        RETVAL = D_U16(obj,6);
    OUTPUT:
        RETVAL

char *
rr_rrsig_signer(obj)
    Net::LDNS::RR::RRSIG obj;
    CODE:
        RETVAL = D_STRING(obj,7);
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);

SV *
rr_rrsig_signature(obj)
    Net::LDNS::RR::RRSIG obj;
    CODE:
    {
        ldns_rdf *rdf = ldns_rr_rdf(obj,8);
        RETVAL = newSVpvn((char*)ldns_rdf_data(rdf), ldns_rdf_size(rdf));
    }
    OUTPUT:
        RETVAL

bool
rr_rrsig_verify_time(obj,rrset_in,keys_in, when, msg)
    Net::LDNS::RR::RRSIG obj;
    AV *rrset_in;
    AV *keys_in;
    time_t when;
    const char *msg;
    CODE:
    {
        size_t i;
        ldns_status s;
        ldns_rr_list *rrset = ldns_rr_list_new();
        ldns_rr_list *keys  = ldns_rr_list_new();
        ldns_rr_list *sig   = ldns_rr_list_new();
        ldns_rr_list *good  = ldns_rr_list_new();

        /* Make a list with only the RRSIG */
        ldns_rr_list_push_rr(sig, obj);

        /* Take RRs out of the array and stick in a list */
        for(i = 0; i <= av_len(rrset_in); ++i)
        {
            ldns_rr *rr;
            SV **rrsv = av_fetch(rrset_in,i,1);
            IV tmp = SvIV((SV*)SvRV(*rrsv));
            rr = INT2PTR(ldns_rr *,tmp);
            if(rr != NULL)
            {
                ldns_rr_list_push_rr(rrset, rr);
            }
        }

        /* Again, for the keys */
        for(i = 0; i <= av_len(keys_in); ++i)
        {
            ldns_rr *rr;
            SV **rrsv = av_fetch(keys_in,i,1);
            IV tmp = SvIV((SV*)SvRV(*rrsv));
            rr = INT2PTR(ldns_rr *,tmp);
            if(rr != NULL)
            {
                ldns_rr_list_push_rr(keys, rr);
            }
        }

        /* And verify using the lists */
        s = ldns_verify_time(rrset, sig, keys, when, good);

        RETVAL = (s == LDNS_STATUS_OK);
        msg = ldns_get_errorstr_by_id(s);

        ldns_rr_list_free(rrset);
        ldns_rr_list_free(keys);
        ldns_rr_list_free(sig);
        ldns_rr_list_free(good);
    }
    OUTPUT:
        RETVAL
        msg

MODULE = Net::LDNS        PACKAGE = Net::LDNS::RR::NSEC             PREFIX=rr_nsec_

char *
rr_nsec_next(obj)
    Net::LDNS::RR::NSEC obj;
    CODE:
        RETVAL = D_STRING(obj,0);
    OUTPUT:
        RETVAL

char *
rr_nsec_typelist(obj)
    Net::LDNS::RR::NSEC obj;
    CODE:
        RETVAL = D_STRING(obj,1);
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);

SV *
rr_nsec_typehref(obj)
    Net::LDNS::RR::NSEC obj;
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
                if(hv_store(res,typestring,pos,newSViv(1),0)==NULL)
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

bool
rr_nsec_covers(obj,name)
    Net::LDNS::RR::NSEC obj;
    const char *name;
    CODE:
        ldns_rdf *dname = ldns_rdf_new_frm_str(LDNS_RDF_TYPE_DNAME, name);
        ldns_dname2canonical(dname);
        ldns_rr2canonical(obj);
        RETVAL = ldns_nsec_covers_name(obj,dname);
    OUTPUT:
        RETVAL

MODULE = Net::LDNS        PACKAGE = Net::LDNS::RR::NSEC3            PREFIX=rr_nsec3_

U8
rr_nsec3_algorithm(obj)
    Net::LDNS::RR::NSEC3 obj;
    CODE:
        RETVAL = ldns_nsec3_algorithm(obj);
    OUTPUT:
        RETVAL

U8
rr_nsec3_flags(obj)
    Net::LDNS::RR::NSEC3 obj;
    CODE:
        RETVAL = ldns_nsec3_flags(obj);
    OUTPUT:
        RETVAL

bool
rr_nsec3_optout(obj)
    Net::LDNS::RR::NSEC3 obj;
    CODE:
        RETVAL = ldns_nsec3_optout(obj);
    OUTPUT:
        RETVAL

U16
rr_nsec3_iterations(obj)
    Net::LDNS::RR::NSEC3 obj;
    CODE:
        RETVAL = ldns_nsec3_iterations(obj);
    OUTPUT:
        RETVAL

SV *
rr_nsec3_salt(obj)
    Net::LDNS::RR::NSEC3 obj;
    PPCODE:
        if(ldns_nsec3_salt_length(obj) > 0)
        {
            ldns_rdf *buf = ldns_nsec3_salt(obj);
            ST(0) = sv_2mortal(newSVpvn((char *)ldns_rdf_data(buf), ldns_rdf_size(buf)));
            ldns_rdf_free(buf);
        }

SV *
rr_nsec3_next_owner(obj)
    Net::LDNS::RR::NSEC3 obj;
    CODE:
        ldns_rdf *buf = ldns_nsec3_next_owner(obj);
        RETVAL = newSVpvn((char *)ldns_rdf_data(buf), ldns_rdf_size(buf));
    OUTPUT:
        RETVAL

char *
rr_nsec3_typelist(obj)
    Net::LDNS::RR::NSEC3 obj;
    CODE:
        RETVAL = ldns_rdf2str(ldns_nsec3_bitmap(obj));
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);

SV *
rr_nsec3_typehref(obj)
    Net::LDNS::RR::NSEC3 obj;
    CODE:
    {
        char *typestring = ldns_rdf2str(ldns_nsec3_bitmap(obj));
        size_t pos;
        HV *res = newHV();

        pos = 0;
        while(typestring[pos] != '\0')
        {
            pos++;
            if(typestring[pos] == ' ')
            {
                typestring[pos] = '\0';
                if(hv_store(res,typestring,pos,newSViv(1),0)==NULL)
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

bool
rr_nsec3_covers(obj,name)
    Net::LDNS::RR::NSEC3 obj;
    const char *name;
    CODE:
    {
        ldns_rr *clone;
        ldns_rdf *dname;
        ldns_rdf *hashed;
        ldns_rdf *chopped;

        clone = ldns_rr_clone(obj);
        dname = ldns_rdf_new_frm_str(LDNS_RDF_TYPE_DNAME, name);
        ldns_dname2canonical(dname);
        ldns_rr2canonical(clone);
        hashed = ldns_nsec3_hash_name_frm_nsec3(clone, dname);
        chopped = ldns_dname_left_chop(dname);
        ldns_dname_cat(hashed,chopped);
        RETVAL = ldns_nsec_covers_name(clone,hashed);
        ldns_rdf_free(hashed);
        ldns_rdf_free(chopped);
        ldns_rr_free(clone);
    }
    OUTPUT:
        RETVAL

MODULE = Net::LDNS        PACKAGE = Net::LDNS::RR::NSEC3PARAM       PREFIX=rr_nsec3param_

U8
rr_nsec3param_algorithm(obj)
    Net::LDNS::RR::NSEC3PARAM obj;
    CODE:
        RETVAL = D_U8(obj,0);
    OUTPUT:
        RETVAL

U8
rr_nsec3param_flags(obj)
    Net::LDNS::RR::NSEC3PARAM obj;
    CODE:
        RETVAL = D_U8(obj,1);
    OUTPUT:
        RETVAL


U16
rr_nsec3param_iterations(obj)
    Net::LDNS::RR::NSEC3PARAM obj;
    CODE:
        RETVAL = D_U16(obj,2);
    OUTPUT:
        RETVAL

SV *
rr_nsec3param_salt(obj)
    Net::LDNS::RR::NSEC3PARAM obj;
    PPCODE:
        ldns_rdf *rdf = ldns_rr_rdf(obj,3);
        if(ldns_rdf_size(rdf) > 0)
        {
            mPUSHs(newSVpvn((char *)ldns_rdf_data(rdf), ldns_rdf_size(rdf)));
        }

MODULE = Net::LDNS        PACKAGE = Net::LDNS::RR::PTR              PREFIX=rr_ptr_

char *
rr_ptr_ptrdname(obj)
    Net::LDNS::RR::PTR obj;
    CODE:
        RETVAL = D_STRING(obj,0);
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);


MODULE = Net::LDNS        PACKAGE = Net::LDNS::RR::CNAME            PREFIX=rr_cname_

char *
rr_cname_cname(obj)
    Net::LDNS::RR::CNAME obj;
    CODE:
        RETVAL = D_STRING(obj,0);
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);


MODULE = Net::LDNS        PACKAGE = Net::LDNS::RR::TXT              PREFIX=rr_txt_

char *
rr_txt_txtdata(obj)
    Net::LDNS::RR::TXT obj;
    CODE:
        RETVAL = D_STRING(obj,0);
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);

MODULE = Net::LDNS        PACKAGE = Net::LDNS::RR::SPF              PREFIX=rr_spf_

char *
rr_spf_spfdata(obj)
    Net::LDNS::RR::SPF obj;
    CODE:
        RETVAL = D_STRING(obj,0);
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);

MODULE = Net::LDNS        PACKAGE = Net::LDNS::RR::KEY           PREFIX=rr_key_

U16
rr_key_flags(obj)
    Net::LDNS::RR::KEY obj;
    CODE:
        RETVAL = D_U16(obj,0);
    OUTPUT:
        RETVAL

U8
rr_key_protocol(obj)
    Net::LDNS::RR::KEY obj;
    CODE:
        RETVAL = D_U8(obj,1);
    OUTPUT:
        RETVAL

U8
rr_key_algorithm(obj)
    Net::LDNS::RR::KEY obj;
    CODE:
        RETVAL = D_U8(obj,2);
    OUTPUT:
        RETVAL

SV *
rr_key_keydata(obj)
    Net::LDNS::RR::KEY obj;
    CODE:
    {
        ldns_rdf *rdf = ldns_rr_rdf(obj,3);
        RETVAL = newSVpvn((char*)ldns_rdf_data(rdf), ldns_rdf_size(rdf));
    }
    OUTPUT:
        RETVAL

MODULE = Net::LDNS        PACKAGE = Net::LDNS::RR::SIG            PREFIX=rr_sig_

char *
rr_sig_typecovered(obj)
    Net::LDNS::RR::SIG obj;
    CODE:
        RETVAL = D_STRING(obj,0);
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);

U8
rr_sig_algorithm(obj)
    Net::LDNS::RR::SIG obj;
    CODE:
        RETVAL = D_U8(obj,1);
    OUTPUT:
        RETVAL

U8
rr_sig_labels(obj)
    Net::LDNS::RR::SIG obj;
    CODE:
        RETVAL = D_U8(obj,2);
    OUTPUT:
        RETVAL

U32
rr_sig_origttl(obj)
    Net::LDNS::RR::SIG obj;
    CODE:
        RETVAL = D_U32(obj,3);
    OUTPUT:
        RETVAL

U32
rr_sig_expiration(obj)
    Net::LDNS::RR::SIG obj;
    CODE:
        RETVAL = D_U32(obj,4);
    OUTPUT:
        RETVAL

U32
rr_sig_inception(obj)
    Net::LDNS::RR::SIG obj;
    CODE:
        RETVAL = D_U32(obj,5);
    OUTPUT:
        RETVAL

U16
rr_sig_keytag(obj)
    Net::LDNS::RR::SIG obj;
    CODE:
        RETVAL = D_U16(obj,6);
    OUTPUT:
        RETVAL

char *
rr_sig_signer(obj)
    Net::LDNS::RR::SIG obj;
    CODE:
        RETVAL = D_STRING(obj,7);
    OUTPUT:
        RETVAL
    CLEANUP:
        free(RETVAL);

SV *
rr_sig_signature(obj)
    Net::LDNS::RR::SIG obj;
    CODE:
    {
        ldns_rdf *rdf = ldns_rr_rdf(obj,8);
        RETVAL = newSVpvn((char*)ldns_rdf_data(rdf), ldns_rdf_size(rdf));
    }
    OUTPUT:
        RETVAL

