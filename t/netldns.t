use Test::More;

BEGIN { use_ok('NetLDNS')}

my $s = NetLDNS->new('8.8.8.8');
isa_ok($s, 'NetLDNS');
my $p = $s->mxquery('nic.se');
isa_ok($p, 'NetLDNS::Packet');
is($p->rcode, 'NOERROR', 'expected rcode');

my $p2 = $s->query('iis.se','NS','IN');
isa_ok($p2, 'NetLDNS::Packet');
is($p2->rcode, 'NOERROR');

ok($p2->qr(), 'QR bit set');

eval { $s->query('nic.se', 'gurksallad', 'CH')};
like($@, qr/Unknown RR type: gurksallad/);

eval { $s->query('nic.se', 'SOA', 'gurksallad')};
like($@, qr/Unknown RR class: gurksallad/);

eval { $s->query('nic.se', 'soa', 'IN')};
ok(!$@);

my @answer = $p2->answer;
is(scalar(@answer), 3, 'expected number of NS records in answer');
foreach my $rr (@answer) {
    isa_ok($rr, 'NetLDNS::RR');
    is($rr->owner, 'iis.se.', 'expected owner name');
}

done_testing;