package Net::LDNS;

use 5.12.4;

our $VERSION = '0.59';
require XSLoader;
XSLoader::load( __PACKAGE__, $VERSION );

use Net::LDNS::RR;
use Net::LDNS::Packet;

1;

=head1 NAME

    Net::LDNS - DNS-talking module based on the ldns C library

=head1 SYNOPSIS

    my $resolver = Net::LDNS->new('8.8.8.8');
    my $packet   = $resolver->query('www.iis.se');
    say $packet->string;

=head1 DESCRIPTION

C<Net::LDNS> represents a resolver, which is the part of the system responsible for sending queries and receiving answers to them.

=head1 FUNCTION

=over

=item lib_version()

Returns the ldns version string.

=back

=head1 CLASS METHOD

=over

=item new($addr,...)

Creates a new resolver object. If given no arguments, if will pick up nameserver addresses from the system configuration (F</etc/resolv.conf> or
equivalent). If given a single argument that is C<undef>, it will not know of any nameservers and all attempts to send queries will throw
exceptions. If given one or more arguments that are not C<undef>, attempts to parse them as IPv4 and IPv6 addresses will be made, and if successful
make up a list of servers to send queries to. If an argument cannot be parsed as an IP address, an exception will be thrown.

=back

=head1 INSTANCE METHODS

=over

=item query($name, $type, $class)

Send a query for the given triple. If type or class are not provided they default to A and IN, respectively. Returns a L<Net::LDNS::Packet> or
undef.

=item name2addr($name)

Asks this resolver to look up A and AAAA records for the given name, and return a list of the IP addresses (as strings). In scalar context, returns
the number of addresses found.

=item addr2name($addr)

Takes an IP address, asks the resolver to do PTR lookups and returns the names found. In scalar context, returns the number of names found.

=item recurse($flag)

Returns the setting of the recursion flag. If given an argument, it will be treated as a boolean and the flag set accordingly.

=item debug($flag)

Gets and optionally sets the debug flag.

=item dnssec($flag)

Get and optionally sets the DNSSEC flag.

=item igntc($flag)

Get and optionally sets the igntc flag.

=item usevc($flag)

Get and optionally sets the usevc flag.

=item retry($count)

Get and optionally set the number of retries.

=item retrans($seconds)

Get and optionally set the number of seconds between retries.

=item axfr_start($domain,$class)

Set this resolver object up for a zone transfer of the specified domain. If C<$class> is not given, it defaults to IN.

=item axfr_next()

Get the next RR in the zone transfer. L<axfr_start()> must have been done before this is called, and after this is called L<axfr_complete()>
should be used to check if there are more records to get. If there's any problem, an exception will be thrown. Basically, the sequence should be
something like:

    $res->axfr_start('example.org');
    do {
        push @rrlist, $res->axfr_next;
    } until $res->axfr_complete;

=item axfr_complete()

Returns false if there is a started zone transfer with more records to get, and true if the started transfer has completed.

=item axfr_last_packet()

If L<axfr_next()> threw an exception, this method returns the L<Net::LDNS::Packet> that made it do so. The packet's RCODE is likely to say what
the problem was (for example, NOTAUTH or NXDOMAIN).

=back
