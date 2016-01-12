use Test::More;

use_ok('Net::LDNS');

SKIP: {
    skip 'no network', 8 if $ENV{TEST_NO_NETWORK};

    my $r = Net::LDNS->new('192.5.6.30');
    isa_ok($r, 'Net::LDNS');
    ok($r->dnssec(1), 'DO flag set.');

    my $p = $r->query('net', 'SOA');

    skip 'Remote server not responding.', 6 if not $p;
    isa_ok($p, 'Net::LDNS::Packet');

    my $rr = $p->opt_rr;
    isa_ok($rr, 'Net::LDNS::RR::OPT');
    is($rr->udp_size, 4096, 'UDP size is 4096.');
    is($rr->extended_rcode, 0, 'Extended RCODE is zero.');
    is($rr->edns_version, 0, 'EDNS version is 0.');
    ok(($rr->edns_z & 0x8000), 'DO bit is set in flags.');
}

done_testing;
