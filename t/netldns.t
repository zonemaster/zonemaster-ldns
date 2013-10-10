use Test::More;
use Devel::Peek;

BEGIN { use_ok('NetLDNS')}
BEGIN { use_ok('NetLDNS::RR')}

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
my %known_ns = map {$_ => 1} qw[ns.nic.se. i.ns.se. ns3.nic.se.];
foreach my $rr (@answer) {
    isa_ok($rr, 'NetLDNS::RR::NS');
    is($rr->owner, 'iis.se.', 'expected owner name');
    ok($rr->ttl > 0, 'positive TTL ('.$rr->ttl.')');
    is($rr->type, 'NS', 'type is NS');
    is($rr->class, 'IN', 'class is IN');
    ok($known_ns{$rr->nsdname}, 'known nsdname ('.$rr->nsdname.')');
}

my %known_mx = map {$_ => 1} qw[mx1.iis.se. mx2.iis.se. ];
foreach my $rr ($p->answer) {
    is($rr->preference, 10, 'expected MX preference');
    ok($known_mx{$rr->exchange}, 'known MX exchange ('.$rr->exchange.')');
}

done_testing;