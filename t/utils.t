use Test::More;

BEGIN{ use_ok('Net::LDNS')}

my $res = new_ok('Net::LDNS');

my @addrs = sort $res->name2addr('b.ns.se');
my $count = $res->name2addr('b.ns.se');

is_deeply(\@addrs, ["192.36.133.107","2001:67c:254c:301::53"], 'expected addresses');
is($count,2,'expected count');

done_testing;