use Test::More;
use Devel::Peek;

BEGIN { use_ok('NetLDNS')}

my $s = NetLDNS->new('8.8.8.8');

my $p = $s->query('iis.se', 'SOA', 'IN');

foreach my $rr ($p->answer) {
    isa_ok($rr, 'NetLDNS::RR::SOA');
    is($rr->mname, 'ns.nic.se.');
    is($rr->rname, 'hostmaster.iis.se.');
    ok($rr->serial >= 1381471502, 'serial');
    is($rr->refresh, 10800, 'refresh');
    is($rr->retry, 3600, 'retry');
    is($rr->expire, 1814400, 'expire');
    is($rr->minimum, 14400, 'minimum');
}

done_testing;