use Test::More;

BEGIN { use_ok('NetLDNS')}

my $s = NetLDNS->new('8.8.8.8');
isa_ok($s, 'NetLDNS');
my $p = $s->mxquery('nic.se');
isa_ok($p, 'NetLDNS::Packet');
is($p->rcode, 'NOERROR', 'expected rcode');

my $p2 = $s->query('iis.se','A','IN');
isa_ok($p2, 'NetLDNS::Packet');
is($p2->rcode, 'NOERROR');

done_testing;