use Test::More;
use Test::Fatal;
use Encode;
use Devel::Peek;

BEGIN { use_ok( "Net::LDNS" => qw[:all] ) }

if (exception {to_idn("whatever")} =~ /libidn not installed/) {
    ok(!has_idn(), 'No IDN');
    done_testing;
    exit;
}

ok(has_idn(), 'Has IDN');
my $encoded = to_idn( decode( 'utf8', 'annaröd.se' ) );
is( $encoded, 'xn--annard-0xa.se', 'One name encoded right' );

my @before = map { decode( 'utf8', $_ ) } ('annaröd.se', 'rindlöw.se', 'räksmörgås.se', 'nic.中國', 'iis.se');
my @many = to_idn @before;
is_deeply(
    \@many,
    [qw( xn--annard-0xa.se xn--rindlw-0xa.se xn--rksmrgs-5wao1o.se nic.xn--fiqz9s iis.se )],
    'Many encoded right'
);

like( exception { to_idn( decode( 'utf8', "ö" x 63 ) ) }, qr/Punycode failed/, 'Boom today' );

done_testing;
