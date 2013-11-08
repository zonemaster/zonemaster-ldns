use Test::More;

use Net::LDNS;

my $r = Net::LDNS->new('8.8.8.8');

$r->recursive(0);
ok(!$r->recursive, 'recursive off');
$r->recursive(1);
ok($r->recursive, 'recursive on');

$r->retrans(17);
is($r->retrans, 17, 'retrans set');

$r->retry(17);
is($r->retry, 17, 'retry set');

$r->debug(1);
ok($r->debug, 'debug set');
$r->debug(0);
ok(!$r->debug, 'debug unset');

$r->dnssec(1);
ok($r->dnssec, 'dnssec set');
$r->dnssec(0);
ok(!$r->dnssec, 'dnssec unset');

$r->usevc(1);
ok($r->usevc, 'usevc set');
$r->usevc(0);
ok(!$r->usevc, 'usevc unset');

$r->igntc(1);
ok($r->igntc, 'igntc set');
$r->igntc(0);
ok(!$r->igntc, 'igntc unset');

done_testing;