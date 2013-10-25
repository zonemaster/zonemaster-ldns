package NetLDNS::RR;

use NetLDNS::RR::A;
use NetLDNS::RR::AAAA;
use NetLDNS::RR::CNAME;
use NetLDNS::RR::DNSKEY;
use NetLDNS::RR::DS;
use NetLDNS::RR::MX;
use NetLDNS::RR::NS;
use NetLDNS::RR::NSEC;
use NetLDNS::RR::NSEC3;
use NetLDNS::RR::NSEC3PARAM;
use NetLDNS::RR::PTR;
use NetLDNS::RR::RRSIG;
use NetLDNS::RR::SOA;
use NetLDNS::RR::TXT;

use overload '<=>' => \&do_compare, 'cmp' => \&do_compare;

sub do_compare {
    my ( $self, $other, $swapped ) = @_;

    return $self->compare($other);
}

1;