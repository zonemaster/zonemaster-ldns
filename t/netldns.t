use Test::More;

BEGIN { use_ok('NetLDNS')}

is(NetLDNS::seventeen(), 17);

my ($n, $str ) = NetLDNS::count("foobar");
is($n, 6);
is($str, 'foobar');

my $s = NetLDNS->new('foobar');
isa_ok($s, 'NetLDNS');
is($s->str, 'foobar');

done_testing;