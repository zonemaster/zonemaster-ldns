use Test::More;
use Test::Fatal;
use Encode;
use Devel::Peek;
use utf8;

BEGIN { use_ok( "Zonemaster::LDNS" => qw[:all] ) }

no warnings 'uninitialized';
if (exception {to_idn("whatever")} =~ /libidn2 not installed/) {
    ok(!has_idn(), 'No IDN');
    done_testing;
    exit;
}

ok(has_idn(), 'Has IDN');
my $encoded = to_idn( 'annaröd.se' );
is( $encoded, 'xn--annard-0xa.se', 'One name encoded right' );

my @before = ('annaröd.se', 'rindlöw.se', 'räksmörgås.se', 'nic.中國', 'iis.se');
my @many = to_idn @before;
is_deeply(
    \@many,
    [qw( xn--annard-0xa.se xn--rindlw-0xa.se xn--rksmrgs-5wao1o.se nic.xn--fiqz9s iis.se )],
    'Many encoded right'
);

like( exception { to_idn( "ö" x 63 ) }, qr/Punycode/i, 'Boom today' );

subtest 'test domain with symbol (backward compatibility)' => sub {
    my $domain = "👍.example";
    $encoded = to_idn( $domain );
    my $expected = "xn--yp8h.example";
    is( $encoded, $expected, 'IDNA2003 supported' );
};

done_testing;
