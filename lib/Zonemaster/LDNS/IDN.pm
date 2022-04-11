package Zonemaster::LDNS::IDN;

use strict;
use warnings;

use Carp;

use parent 'Exporter';
our @EXPORT_OK = qw[has_idn to_idn];

my $idn_available = 0;

eval {
    use Net::LibIDN2 ':all';
};

if ( ! $@ ) {
    $idn_available = 1;
}

sub has_idn {
    return $idn_available;
}

sub to_idn {
    if ( !has_idn() ) {
        croak( "Module Net::LibIDN2 not installed." );
    }

    my @dst;
    for ( @_ ) {
        my $rc = -1;
        my $out = Net::LibIDN2::idn2_to_ascii_8( $_, IDN2_NFC_INPUT, $rc );
        if ( $rc == IDN2_OK ) {
            push @dst, $out;
        }
        else {
          croak( "Error: %s\n", Net::LibIDN2::idn2_strerror( $rc ) );
        }
    }

    if ( scalar @dst > 1 ) {
        return @dst;
    } else {
        return $dst[0];
    }
}
