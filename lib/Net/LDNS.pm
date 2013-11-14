package Net::LDNS;

use 5.14.2;

our $VERSION = '0.1';
require XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

use Net::LDNS::RR;
use Net::LDNS::Packet;

our %destroyed;

sub DESTROY {
    my ($self) = @_;

    if (not $destroyed{$self->addr}) {
        $destroyed{$self->addr} = 1;
        $self->free;
    }

    return;
}

1;