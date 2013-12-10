use Test::More;

use Net::LDNS;

my $r = Net::LDNS->new( '8.8.8.8' );

$r->recurse( 0 );
ok( !$r->recurse, 'recursive off' );
$r->recurse( 1 );
ok( $r->recurse, 'recursive on' );

$r->retrans( 17 );
is( $r->retrans, 17, 'retrans set' );

$r->retry( 17 );
is( $r->retry, 17, 'retry set' );

$r->debug( 1 );
ok( $r->debug, 'debug set' );
$r->debug( 0 );
ok( !$r->debug, 'debug unset' );

$r->dnssec( 1 );
ok( $r->dnssec, 'dnssec set' );
$r->dnssec( 0 );
ok( !$r->dnssec, 'dnssec unset' );

$r->usevc( 1 );
ok( $r->usevc, 'usevc set' );
$r->usevc( 0 );
ok( !$r->usevc, 'usevc unset' );

$r->igntc( 1 );
ok( $r->igntc, 'igntc set' );
$r->igntc( 0 );
ok( !$r->igntc, 'igntc unset' );

my $res = new_ok( 'Net::LDNS' );
my $p   = $res->query( 'www.iis.se' );
isa_ok( $p, 'Net::LDNS::Packet' );
isa_ok( $_, 'Net::LDNS::RR::A' ) for $p->answer;

$res = Net::LDNS->new( '194.146.106.22' );
$p   = $res->query( 'www.iis.se' );
is( scalar( $p->answer ),     1, 'answer count in scalar context' );
is( scalar( $p->authority ),  3, 'authority count in scalar context' );
is( scalar( $p->additional ), 6, 'additional count in scalar context' );
is( scalar( $p->question ),   1, 'question count in scalar context' );

my $none = Net::LDNS->new( undef );
isa_ok( $none, 'Net::LDNS' );
my $pn = eval { $none->query( 'iis.se' ) };
like( $@, qr/No \(valid\) nameservers defined in the resolver/ );
ok( !$pn );

my $b0rken = eval { Net::LDNS->new( 'gurksallad' ) };
ok( !$b0rken );
like( $@, qr/Failed to parse IP address: gurksallad/ );

done_testing;
