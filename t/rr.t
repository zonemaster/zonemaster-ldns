use Test::More;
use Devel::Peek;
use MIME::Base64;

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

$p = $s->query('a.ns.se', 'A', 'IN');
foreach my $rr ($p->answer) {
    isa_ok($rr, 'NetLDNS::RR::A');
    is($rr->address, '192.36.144.107', 'expected address string');
}

$p = $s->query('a.ns.se', 'AAAA', 'IN');
foreach my $rr ($p->answer) {
    isa_ok($rr, 'NetLDNS::RR::AAAA');
    is($rr->address, '2a01:03f0:0000:0301:0000:0000:0000:0053', 'expected address string');
}

my $se = NetLDNS->new('192.36.144.107');
my $pt = $se->query('se','TXT','IN');
foreach my $rr ($pt->answer) {
    isa_ok($rr, 'NetLDNS::RR::TXT');
    like($rr->txtdata, qr/^"SE zone update: /);
}

my $pk = $se->query('se', 'DNSKEY', 'IN');
foreach my $rr ($pk->answer) {
    isa_ok($rr, 'NetLDNS::RR::DNSKEY');
    ok($rr->flags == 256 or $rr->flags == 257);
    is($rr->protocol, 3);
    is($rr->algorithm, 5);
}

my $pr = $se->query('se', 'RRSIG', 'IN');
foreach my $rr ($pr->answer) {
    isa_ok($rr, 'NetLDNS::RR::RRSIG');
    is($rr->signer, 'se.');
    is($rr->labels, 1);
    if ($rr->typecovered eq 'DNSKEY') {
        is($rr->keytag, 59747);
    } else {
        is($rr->keytag, 27646);
    }
}


done_testing;