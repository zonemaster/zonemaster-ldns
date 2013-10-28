package Net::LDNS::RR;

use Net::LDNS::RR::A;
use Net::LDNS::RR::AAAA;
use Net::LDNS::RR::CNAME;
use Net::LDNS::RR::DNSKEY;
use Net::LDNS::RR::DS;
use Net::LDNS::RR::MX;
use Net::LDNS::RR::NS;
use Net::LDNS::RR::NSEC;
use Net::LDNS::RR::NSEC3;
use Net::LDNS::RR::NSEC3PARAM;
use Net::LDNS::RR::PTR;
use Net::LDNS::RR::RRSIG;
use Net::LDNS::RR::SOA;
use Net::LDNS::RR::TXT;

use overload '<=>' => \&do_compare, 'cmp' => \&do_compare, '""' => \&to_string;

sub do_compare {
    my ( $self, $other, $swapped ) = @_;

    return $self->compare($other);
}

sub to_string {
    my ($self) = @_;

    return $self->string;
}

1;