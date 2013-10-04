use Test::More;

BEGIN { use_ok('NetLDNS')}

my $s = NetLDNS->new('8.8.8.8');
isa_ok($s, 'NetLDNS');
my $p = $s->mxquery('nic.se');
isa_ok($p, 'NetLDNS::Packet');

is($p->rcode, 'NOERROR', 'expected rcode');

done_testing;