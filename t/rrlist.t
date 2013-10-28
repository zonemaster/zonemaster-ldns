use Test::More;
use Devel::Peek;

use Net::LDNS;

my $s = Net::LDNS->new('8.8.8.8');
my $p = $s->query('iis.se', 'SOA');

my $rrl = $p->all;
isa_ok($rrl, 'Net::LDNS::RRList');

done_testing;