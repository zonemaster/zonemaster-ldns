
package Net::LDNS::RR::OPT;

1;

=head1 NAME

Net::LDNS::RR::OPT - EDNS0 pseduo-RR

=head1 DESCRIPTION

Class representing the special OPT pseudo-RR used for EDNS0. See RFC 2671.

=head1 METHODS

=over

=item udp_size()

Get the UDP data size value.

=item extended_rcode()

Get the extended RCODE field. Note that this is only the upper eight bits of the full 12-bit extended RCODE. 

=item edns_version()

Get the EDNS version number. If this is not zero, something weird is going on.

=item edns_z()

The 16-bit flag field. The only defined flag as of this writing is the DNSSEC DO flag in the topmost bit.

=back

=cut
