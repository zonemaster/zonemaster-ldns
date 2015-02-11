#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <ldns/ldns.h>

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
