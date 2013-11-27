package Net::LDNS::Packet;

use 5.12.4;

use Net::LDNS;

use MIME::Base64;

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

1;

=head1 NAME

Net::LDNS::Packet - objects representing DNS packets

=head1 SYNOPSIS

    my $p = $resolver->query('www.iis.se');
    foreach my $rr ($p->answer) {
        say $rr->string if $rr->type eq 'A';
    }

=head1 CLASS METHODS

=over

=item new($name, $type, $class)

Create a new packet, holding nothing by a query record for the provided triplet. C<$type> and C<$class> are optional, and default to A and IN
respectively.

=item new_from_wireformat($data)

Creates a new L<Net::LDNS::Packet> object from the given wireformat data, if possible. Throws an exception if not.

=back

=head1 INSTANCE METHODS

=over

=item rcode()

Returns the packet RCODE.

=item opcode()

Returns the packet OPCODE.

=item id()

Returns the packet id number.

=item aa()
=item tc()
=item rd()
=item cd()
=item ra()
=item ad()
=item do()

Returns the equivalently named flags.

=item size()

Returns the length of the packet's wireformat form in octets.

=item querytime()

Returns the time the query this packet is the answer to took to execute, i milliseconds.

=item answerfrom($ipaddr)

Returns and optionally sets the IP address the packet was received from. If an attempt is made to set it to a string that cannot be parsed as an
IPv4 or IPv6 address, an exception is thrown.

=item timestamp($time)

The time when the query was sent or received (the ldns docs don't specify), as a floating-point value on the Unix time_t scale (that is, the same
kind of value used by L<Time::HiRes::time()>). Conversion effects between floating-point and C<struct timeval> means that the precision of the
value is probably not reliable at the microsecond level, even if you computer's clock happen to be.

=item question()
=item answer()
=item authority()
=item additional()

Returns list of objects representing the RRs in the named section. They will be of classes appropriate to their types, but all will have
C<Net::LDNS::RR> as a base class.

=item unique_push($section, $rr)

Push an RR object into the given section, if an identical RR isn't already present. If the section isn't one of "question", "answer", "authority"
or "additional" an exception will be thrown. C<$rr> must be a L<Net::LDNS::RR> subclass.

=item string()

Returns a string with the packet and its contents in common presentation format.

=item wireformat()

Returns a Perl string holding the packet in wire format.

=back
