use Test::More;
use Devel::Peek;

BEGIN { use_ok('NetLDNS')}

my $s = NetLDNS->new('8.8.8.8');
isa_ok($s, 'NetLDNS');
my $p = $s->query('nic.se', 'MX');
isa_ok($p, 'NetLDNS::Packet');
is($p->rcode, 'NOERROR', 'expected rcode');

my $p2 = $s->query('iis.se','NS','IN');
isa_ok($p2, 'NetLDNS::Packet');
is($p2->rcode, 'NOERROR');

ok($p2->id() > 0, 'packet ID set');
ok($p2->qr(), 'QR bit set');
ok(!$p2->aa(), 'AA bit not set');
ok(!$p2->tc(), 'TC bit not set');
ok($p2->rd(), 'RD bit set');
ok(!$p2->cd(), 'CD bit not set');
ok($p2->ra(), 'RA bit set');
ok(!$p2->ad(), 'AD bit not set');

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

my $lroot = NetLDNS->new('199.7.83.42');
my $se = $lroot->query('se', 'NS');

my @se_q = $se->question;
my @se_ans = $se->answer;
my @se_auth = $se->authority;
my @se_add = $se->additional;

is(scalar(@se_q), 1, 'one question');
is(scalar(@se_ans), 0, 'zero answers');
is(scalar(@se_auth), 9, 'nine authority');
is(scalar(@se_add), 16, 'sixteen additional');

done_testing;