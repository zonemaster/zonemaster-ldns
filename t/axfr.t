use Test::More;

BEGIN { use_ok( 'Net::LDNS' ) }

my $res = Net::LDNS->new( '79.99.7.203' );

ok( $res->axfr_start( 'cyberpomo.com' ), 'AXFR started' );
do {
 my $rr = $res->axfr_next;
 isa_ok( $rr, 'Net::LDNS::RR' );
} until $res->axfr_complete;

my $res2 = Net::LDNS->new( '192.36.144.107' );
ok( $res2->axfr_start( 'iis.se' ) );
eval { $res2->axfr_next };
like( $@, qr/AXFR error/ );
my $pkt = $res2->axfr_last_packet;
isa_ok( $pkt, 'Net::LDNS::Packet' );
is( $pkt->rcode, 'NOTAUTH' );

my $counter = 0;
my $return = $res->axfr( 'cyberpomo.com',
    sub {
        my ($rr) = @_;
        $counter += 1;
        if ($rr->type eq 'CNAME') {
            return 0;
        } else {
            return 1;
        }
    });
ok(!$return, 'Terminated early');
ok(($counter > 1), 'Saw more than one entry (' . $counter . ')');

done_testing;
