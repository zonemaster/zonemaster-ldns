package Net::LDNS;

use 5.14.2;

our $VERSION = '0.1';
require XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

use Net::LDNS::RR;

our %destroyed;

sub DESTROY {
    my ($self) = @_;

    if ($destroyed{$self->addr}) {
        # say STDERR "NOT DESTROYING RESOLVER: " . $self->addr;
    } else {
        $destroyed{$self->addr} = 1;
        # say STDERR "DESTROYING RESOLVER: " . $self->addr;
        $self->free;
    }

    return;
}

1;