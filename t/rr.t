use Test::More;
use Devel::Peek;
use MIME::Base64;

BEGIN { use_ok('NetLDNS')}

my $s = NetLDNS->new('8.8.8.8');

my $p = $s->query('iis.se', 'SOA');

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

$p = $s->query('a.ns.se');
foreach my $rr ($p->answer) {
    isa_ok($rr, 'NetLDNS::RR::A');
    is($rr->address, '192.36.144.107', 'expected address string');
}

$p = $s->query('a.ns.se', 'AAAA');
foreach my $rr ($p->answer) {
    isa_ok($rr, 'NetLDNS::RR::AAAA');
    is($rr->address, '2a01:3f0:0:301::53', 'expected address string');
}

my $se = NetLDNS->new('192.36.144.107');
my $pt = $se->query('se','TXT');
foreach my $rr ($pt->answer) {
    isa_ok($rr, 'NetLDNS::RR::TXT');
    like($rr->txtdata, qr/^"SE zone update: /);
}

my $pk = $se->query('se', 'DNSKEY');
foreach my $rr ($pk->answer) {
    isa_ok($rr, 'NetLDNS::RR::DNSKEY');
    ok($rr->flags == 256 or $rr->flags == 257);
    is($rr->protocol, 3);
    is($rr->algorithm, 5);
}

my $pr = $se->query('se', 'RRSIG');
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

my $pn = $se->query('se', 'NSEC');
foreach my $rr ($pn->answer) {
    isa_ok($rr,'NetLDNS::RR::NSEC');
    ok($rr->typehref->{TXT});
    ok(!$rr->typehref->{MX});
    ok($rr->typehref->{TXT});
    is($rr->typelist, 'NS SOA TXT RRSIG NSEC DNSKEY ');
}

my $pd = $se->query('nic.se', 'DS');
foreach my $rr ($pd->answer) {
    isa_ok($rr, 'NetLDNS::RR::DS');
    is($rr->keytag, 16696);
    is($rr->algorithm, 5);
    ok($rr->digtype == 1 or $rr->digtype == 2);
    ok($rr->hexdigest eq '40079ddf8d09e7f10bb248a69b6630478a28ef969dde399f95bc3b39f8cbacd7' or $rr->hexdigest eq 'ef5d421412a5eaf1230071affd4f585e3b2b1a60');
}

done_testing;