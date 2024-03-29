use Test::More;

BEGIN { use_ok( 'Zonemaster::LDNS' ); }

my $key1 = Zonemaster::LDNS::RR->new(
"iis.se.	2395	IN	DNSKEY	257 3 5 AwEAAcq5u+qe5VibnyvSnGU20panweAk2QxflGVuVQhzQABQV4SIdAQs +LNVHF61lcxe504jhPmjeQ656X6t+dHpRz1DdPO/ukcIITjIRoJHqS+X XyL6gUluZoDU+K6vpxkGJx5m5n4boRTKCTUAR/9rw2+IQRRTtb6nBwsC 3pmf9IlJQjQMb1cQTb0UO7fYgXDZIYVul2LwGpKRrMJ6Ul1nepkSxTMw Q4H9iKE9FhqPeIpzU9dnXGtJ+ZCx9tWSZ9VsSLWBJtUwoE6ZfIoF1ioq qxfGl9JV1/6GkDxo3pMN2edhkp8aqoo/R+mrJYi0vE8jbXvhZ12151Dy wuSxbGjAlxk="
);
my $key2 = Zonemaster::LDNS::RR->new(
"iis.se.	1591	IN	DNSKEY	256 3 5 BQEAAAABuWpCewwMRD7yPzy6TGsymMAc82IHVGB+vjKVIAYKbPG7QxuLEtEzUxDJo09gLN2/N0OF+NnTkmDMj8KA+eIgtqmMuq5kdDVc+eSNLJZ0 am0o27UEkXmW20iV0d6B/KW1X1nufzBSaacUzkBKyDfK4cN3aVsYIDXT H7Jw1agEzrM="
);
my $soa = Zonemaster::LDNS::RR->new( "iis.se.	3600	IN	SOA	ns.nic.se. hostmaster.iis.se. 1384853101 10800 3600 1814400 14400" );
my $sig = Zonemaster::LDNS::RR->new(
"iis.se.	3600	IN	RRSIG	SOA 5 2 3600 20131129082501 20131119082501 59213 iis.se. ShhhfRT82jfA/J1AAqiie/4r7JuiYOpK6dIwugOtlf0/UpVsOYEIukpe Bq9i7fsa0GNWz/o9gqF8DnsCHzgxZnAngTrJpZAlsrC/FP/6v8WfnFsP LDw9g6Ow8Z6TL9JmZr22YPp27Rwujdb5AnzdurEvQxIAqW66CCCy2pc9 //s="
);

is( $sig->keytag, $key2->keytag );

ok( !$sig->verify( [$soa], [ $key1, $key2 ] ), 'Signature does not verify (expired).' );
ok( !$sig->verify( [$soa], [$key1] ), 'Signature does not verify (wrong key).' );

is(
    $sig->verify_str( [$soa], [ $key1, $key2 ] ),
    'DNSSEC signature has expired',
    'Expected unsuccessful verification message.'
);
is(
    $sig->verify_str( [$soa], [$key1] ),
    'No keys with the keytag and algorithm from the RRSIG found',
    'Expected unsuccessful verification message.'
);

my $msg = '';
my $res = $sig->verify_time( [$soa], [ $key1, $key2 ], 1385628478, $msg );
ok( $res, 'Verified OK in the past.' );
is( $msg, 'All OK', 'Expected verification message' );

my $ds1 = $key1->ds( 'sha1' );
isa_ok( $ds1, 'Zonemaster::LDNS::RR::DS', 'sha1' );
ok( $ds1->verify( $key1 ) ) if $ds1;

my $ds2 = $key1->ds( 'sha256' );
isa_ok( $ds2, 'Zonemaster::LDNS::RR::DS', 'sha256' );
ok( $ds2->verify( $key1 ) ) if $ds2;

my $ds3 = $key1->ds( 'sha384' );
isa_ok( $ds3, 'Zonemaster::LDNS::RR::DS', 'sha384' );
ok( $ds3->verify( $key1 ) ) if $ds3;

my $ds4 = $key1->ds( 'gost' );
if ( $ds4 ) {    # We may not have GOST available.
    isa_ok( $ds4, 'Zonemaster::LDNS::RR::DS', 'gost' );
    ok( $ds4->verify( $key1 ) ) if $ds4;
}

is($key1->keysize, 2048, 'Key is 2048 bits long');
is($key2->keysize, 1024, 'Key is 1024 bits long');

my $nsec = Zonemaster::LDNS::RR->new('xx.se.			7200	IN	NSEC	xx0r.se. NS RRSIG NSEC');
isa_ok($nsec, 'Zonemaster::LDNS::RR::NSEC');
ok($nsec->covers('xx-example.se'), 'Covers xx-example.se');

ok(!$nsec->covers('.'), 'Does not cover the root domain');

my $nsec3 = Zonemaster::LDNS::RR->new('NR2E513KM693MBTNVHH56ENF54F886T0.com. 86400 IN NSEC3 1 1 0 - NR2FUHQVR56LH70L6F971J3L6N1RH2TU NS DS RRSIG');
isa_ok($nsec3, 'Zonemaster::LDNS::RR::NSEC3');
ok($nsec3->covers('xx-example.com'), 'Covers xx-example.com');

is($nsec3->covers('.'), undef, 'Does not cover the root domain');

subtest 'malformed NSEC3 do not cover anything' => sub {
    # Malformed resource record lacking a next hashed owner name field in its
    # RDATA. The only way to synthesize such a datum is to use the RFC 3597
    # syntax.
    my $example = Zonemaster::LDNS::RR->new(
        q{example. 0 IN NSEC3 \# 15 01 00 0001 01 AB 00 0006 400000000002}
    );
    is( $example->covers("example"), undef );

    # NSEC3 resource record whose owner name is the root name. This should
    # normally not happen.
    $example = Zonemaster::LDNS::RR->new(
        q{.        0 IN NSEC3 1 0 1 ab 01234567 A RRSIG}
    );
    is( $example->covers("example"), undef );
};

SKIP: {
    skip 'no network', 3 unless $ENV{TEST_WITH_NETWORK};

    $res = Zonemaster::LDNS->new( '212.247.7.228' );
    $res->dnssec( 1 );
    my $p1 = eval { $res->query('www.iis.se', 'A') };

    skip 'Remote server not responding', 3 if not $p1;

    ok( $p1->needs_edns, 'Needs EDNS0');
    ok( $p1->has_edns, 'Alias is there');
    ok( ($p1->edns_size > 0), 'EDNS0 size larger than zero' );
}

done_testing;
