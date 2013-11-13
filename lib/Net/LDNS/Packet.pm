package Net::LDNS::Packet;

use 5.14.2;

use Net::LDNS;

our %destroyed;

sub data {
    my ( $self ) = @_;

    return $self->wireformat;
}

sub DESTROY {
    my ( $self ) = @_;

    if($destroyed{$self->addr}) {
        # say STDERR "NOT DESTROYING PACKET: " . $self->addr;
    }
    else {
        $destroyed{$self->addr} = 1;
        $self->free;
    }
    return;
}

1;