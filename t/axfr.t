use Test::More;

BEGIN { use_ok('Net::LDNS')}

my $res = Net::LDNS->new('79.99.7.203');

ok($res->axfr_start('cyberpomo.com'), 'AXFR started');
do {
    my $rr = $res->axfr_next;
    if (ref($rr) !~ /::TYPE\d+$/) { # Don't die on BIND auto-signed zones
        isa_ok($rr, 'Net::LDNS::RR');
    }
} until $res->axfr_complete;

done_testing;