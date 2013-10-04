use Test::More;

BEGIN { use_ok('NetLDNS')}

my $s = NetLDNS->new('8.8.8.8');
isa_ok($s, 'NetLDNS');
my $rcode = $s->mxquery('nic.se');
is($rcode, 'NOERROR');

done_testing;