package Net::LDNS::Packet;

use 5.14.2;

use Net::LDNS;

use MIME::Base64;

our %destroyed;

sub TO_JSON {
    my ( $self ) = @_;

    return {
        'Net::LDNS::Packet' => {
            data       => encode_base64( $self->wireformat, '' ),
            answerfrom => $self->answerfrom,
            timestamp  => $self->timestamp,
        }
    };
}

sub data {
    my ( $self ) = @_;

    return $self->wireformat;
}

sub DESTROY {
    my ( $self ) = @_;

    if ( not $destroyed{ $self->addr } ) {
        $destroyed{ $self->addr } = 1;
        $self->free;
    }
    return;
}

1;
