use Test::More;

use NetLDNS;

my $r = NetLDNS->new('8.8.8.8');

$r->set_recursive(0);
ok(!$r->recursive, 'recursive off');
$r->set_recursive(1);
ok($r->recursive, 'recursive on');

$r->set_retrans(17);
is($r->retrans, 17, 'retrans set');

$r->set_retry(17);
is($r->retry, 17, 'retry set');

$r->set_debug(1);
ok($r->debug, 'debug set');
$r->set_debug(0);
ok(!$r->debug, 'debug unset');

$r->set_dnssec(1);
ok($r->dnssec, 'dnssec set');
$r->set_dnssec(0);
ok(!$r->dnssec, 'dnssec unset');

$r->set_usevc(1);
ok($r->usevc, 'usevc set');
$r->set_usevc(0);
ok(!$r->usevc, 'usevc unset');

$r->set_igntc(1);
ok($r->igntc, 'igntc set');
$r->set_igntc(0);
ok(!$r->igntc, 'igntc unset');

done_testing;