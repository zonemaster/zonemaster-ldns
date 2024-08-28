use Test::More;
use Test::Exception;
use Test::Differences;
use Devel::Peek;

use Zonemaster::LDNS;

subtest "Good RRList" => sub {
    my $rr1 = Zonemaster::LDNS::RR->new_from_string( 'example. 10 IN NS ns1.example.' );
    my $rr2 = Zonemaster::LDNS::RR->new_from_string( 'example. 10 IN NS ns2.example.' );

    my $rrlist = Zonemaster::LDNS::RRList->new( [ $rr1, $rr2 ] );

    is( $rrlist->count, 2, 'Two in RRList' );
    eq_or_diff $rrlist->string,
               "example.\t10\tIN\tNS\tns1.example.\nexample.\t10\tIN\tNS\tns2.example.",
               'RRList string match';
    isa_ok( $rrlist->get(0), 'Zonemaster::LDNS::RR');
    isa_ok( $rrlist->get(0), 'Zonemaster::LDNS::RR::NS');

    my $rrlist_reversed = Zonemaster::LDNS::RRList->new( [ $rr2, $rr1 ] );

    ok( $rrlist eq $rrlist_reversed, 'Equal RRLists' );

    subtest "RRset" => sub {
        subtest "Same TTL and owner name" => sub {
            ok( $rrlist->is_rrset,    'Is a RRset with same TTL and owner name' );
        };

        subtest "Different CLASS" => sub {
            my $rr3 = Zonemaster::LDNS::RR->new_from_string( 'example. 10 CH NS ns3.example.' );
            my $rrlist2 = Zonemaster::LDNS::RRList->new( [ $rr1, $rr3 ] );
            ok( !$rrlist2->is_rrset,    'Is not a RRset with different CLASS' );
        };

        subtest "Different TYPE" => sub {
            my $rr3 = Zonemaster::LDNS::RR->new_from_string( 'example. 10 IN TXT ns3.example.' );
            my $rrlist2 = Zonemaster::LDNS::RRList->new( [ $rr1, $rr3 ] );
            ok( !$rrlist2->is_rrset,    'Is not a RRset with different TYPE' );
        };

        SKIP: {
            # Skipped due to a bug in LDNS, see https://github.com/NLnetLabs/ldns/pull/251
            skip "Further is_rrset() testing disabled due to an issue in LDNS", 1;

            subtest "Different TTL" => sub {
                my $rr3 = Zonemaster::LDNS::RR->new_from_string( 'example. 20 IN NS ns3.example.' );
                my $rrlist2 = Zonemaster::LDNS::RRList->new( [ $rr1, $rr3 ] );
                ok( !$rrlist2->is_rrset,    'Is not a RRset with different TTL' );
            };

            subtest "Case varying owner name" => sub {
                my $rr3 = Zonemaster::LDNS::RR->new_from_string( 'eXamPle. 20 IN NS ns3.example.' );
                my $rrlist2 = Zonemaster::LDNS::RRList->new( [ $rr2, $rr3 ] );
                ok( $rrlist2->is_rrset,    'Is a RRset with case varying owner names' );
            };
        }
    };

    my $rr3 = Zonemaster::LDNS::RR->new_from_string( 'example. 10 IN A 127.0.0.1' );

    ok( $rrlist->push( $rr3 ), 'Push OK' );
    is( $rrlist->count, 3,     'Three RRs in RRList' );
    isa_ok( $rrlist->get(2), 'Zonemaster::LDNS::RR');
    isa_ok( $rrlist->get(2), 'Zonemaster::LDNS::RR::A');

    is( $rrlist->get(3), undef, 'No RR here');

    while ( my $rr = $rrlist->pop ) {
        isa_ok( $rr, 'Zonemaster::LDNS::RR' );
    }
    is( $rrlist->count, 0, 'Zero RRs in RRList' );
    ok( !$rrlist->is_rrset, 'Is not a RRset' );

    is( $rrlist->get(0), undef, 'No RR here');
};

subtest "Bad RRList" => sub {
    my $rr1 = 'example. IN NS ns1.example.';
    my $rr2 = 'example. IN NS ns2.example.';

    my @rrs = ( $rr1, $rr2 );

    throws_ok { Zonemaster::LDNS::RRList->new( \@rrs ) } qr/Incorrect type in list/, 'crashes on incorrect type';
};

done_testing;
