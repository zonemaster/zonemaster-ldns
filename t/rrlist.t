use Test::More;
use Devel::Peek;

use NetLDNS;

my $s = NetLDNS->new('8.8.8.8');
my $p = $s->query('iis.se', 'SOA');

my $rrl = $p->all;
isa_ok($rrl, 'NetLDNS::RRList');

done_testing;