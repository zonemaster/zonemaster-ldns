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

use Carp;

use overload '<=>' => \&do_compare, 'cmp' => \&do_compare, '""' => \&to_string;

sub new {
    my ( $class, $string ) = @_;

    if ($string) {
        return $class->new_from_string($string);
    } else {
        croak "Must provide string to create RR";
    }
}

sub name {
    my ( $self ) = @_;

    return $self->owner;
}

sub do_compare {
    my ( $self, $other, $swapped ) = @_;

    return $self->compare($other);
}

sub to_string {
    my ($self) = @_;

    return $self->string;
}

1;

=head1 NAME

Net::LDNS::RR - common baseclass for all classes representing resource records.

=head1 SYNOPSIS

    my $rr = Net::LDNS::RR->new('www.iis.se IN A 91.226.36.46');

=head1 OVERLOADS

This class overloads stringify and comparisons ('""', '<=>' and 'cmp').

=head1 CLASS METHOD

=over

=item new($string)

Creates a new RR object of a suitable subclass, given a string representing an RR in common presentation format.

=back

=head1 INSTANCE METHODS

=over

=item owner()

=item name()

These two both return the owner name of the RR.

=item ttl()

Returns the ttl of the RR.

=item type()

Return the type of the RR.

=item class()

Returns the class of the RR.

=item string()

Returns a string with the RR in presentation format.

=item do_compare($other)

Calls the XS C<compare> method with the arguments it needs, rather than the ones overloading gives.

=item to_string

Calls the XS C<string> method with the arguments it needs, rather than the ones overloading gives. Functionally identical to L<string()> from the
Perl level, except for being a tiny little bit slower.

=back