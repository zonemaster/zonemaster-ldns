use Test::More;
use Devel::Peek;

BEGIN { use_ok('Net::LDNS')}

my $s = Net::LDNS->new('8.8.8.8');
isa_ok($s, 'Net::LDNS');
my $p = $s->query('nic.se', 'MX');
isa_ok($p, 'Net::LDNS::Packet');
is($p->rcode, 'NOERROR', 'expected rcode');

my $p2 = $s->query('iis.se','NS','IN');
isa_ok($p2, 'Net::LDNS::Packet');
is($p2->rcode, 'NOERROR');
is($p2->opcode, 'QUERY', 'expected opcode');
my $pround = Net::LDNS::Packet->new_from_wireformat($p2->wireformat);
isa_ok($pround, 'Net::LDNS::Packet');
is($pround->opcode, $p2->opcode, 'roundtrip opcode OK');
is($pround->rcode, $p2->rcode, 'roundtrip rcode OK');

ok($p2->id() > 0, 'packet ID set');
ok($p2->qr(), 'QR bit set');
ok(!$p2->aa(), 'AA bit not set');
ok(!$p2->tc(), 'TC bit not set');
ok($p2->rd(), 'RD bit set');
ok(!$p2->cd(), 'CD bit not set');
ok($p2->ra(), 'RA bit set');
ok(!$p2->ad(), 'AD bit not set');
ok(!$p2->do(), 'DO bit not set');

is($p2->size, 82, 'expected size');
ok($p2->querytime > 0);
is($p2->answerfrom, '8.8.8.8', 'expected answerfrom');
my $diff = $p2->timestamp - time();
ok(($diff >= 0 and $diff < 1), 'timestamp looks reasonable');

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
    isa_ok($rr, 'Net::LDNS::RR::NS');
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

my $lroot = Net::LDNS->new('199.7.83.42');
my $se = $lroot->query('se', 'NS');

is(scalar($se->question), 1, 'one question');
is(scalar($se->answer), 0, 'zero answers');
is(scalar($se->authority), 9, 'nine authority');
is(scalar($se->additional), 16, 'sixteen additional');

my $rr = Net::LDNS::RR->new_from_string('se. 172800	IN	SOA	catcher-in-the-rye.nic.se. registry-default.nic.se. 2013111305 1800 1800 864000 7200');
ok($se->unique_push('answer', $rr), 'unique_push returns ok');
is($se->answer, 1, 'one record in answer section');
ok(!$se->unique_push('answer', $rr), 'unique_push returns false');
is($se->answer, 1, 'still one record in answer section');

my $made = Net::LDNS::Packet->new('foo.com','SOA','IN');
isa_ok($made, 'Net::LDNS::Packet');

done_testing;