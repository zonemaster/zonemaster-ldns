use strict;
use warnings;
use v5.16;

use utf8;

use open ':std', ':encoding(UTF-8)';
use Test::More;
use Test::Fatal qw(exception lives_ok);
use MIME::Base64;
use Test::Differences;

BEGIN { use_ok( 'Zonemaster::LDNS' ) }

sub test_ede {
    my ( $packet, $expected_ede, $expected_extra_text ) = @_;

    my $expected_ede_message = (defined $expected_ede) ? 
        'Got expected EDE' : 'Got no EDE';
    my $expected_ede_text_message = (defined $expected_extra_text) ? 
        'Got expected extra text' : 'Got no extra text';

    {
        my $ede;
        is(
            exception { $ede = $packet->ede() },
            undef,
            'ede() method works in scalar context'
        );
        is( $ede, $expected_ede, $expected_ede_message );
    }
    {
        my ( $ede, $extra_text );
        is(
            exception { ( $ede, $extra_text ) = $packet->ede() },
            undef,
            'ede() method works in list context'
        );
        is( $ede, $expected_ede, $expected_ede_message );
        is( $extra_text, $expected_extra_text, $expected_ede_text_message );
    }
}

#
# This test packet was obtained by performing the following query:
#
# % dig @ns1.ede-13.extended-dns-errors.com TXT ede-13.extended-dns-errors.com.
#
# It contains an EDE 13 (Cached Error) with the extra text “This EDE was
# intentionally inserted by dnsdist”.
#
subtest 'Packet with EDE + ASCII text' => sub {
    my $p = Zonemaster::LDNS::Packet->new_from_wireformat(decode_base64(<<DATA));
jCGFAAABAAAAAQABBmVkZS0xMxNleHRlbmRlZC1kbnMtZXJyb3JzA2NvbQAAEAABwAwABgABAAACWA
AnA25zMcAMCmhvc3RtYXN0ZXLADAE1ALUAAFRgAAAOEAAJOoAAAVGAAAApBNAAAAAAAFAACgAY2Jns
Gd/Ahl4BAAAAac0D6x4N9CxTQ07sAA8AMAANVGhpcyBFREUgd2FzIGludGVudGlvbmFsbHkgaW5zZX
J0ZWQgYnkgZG5zZGlzdA==
DATA

    test_ede( $p, 13, 'This EDE was intentionally inserted by dnsdist' );
};

#
# This test packet was obtained by performing the following query:
#
# % dig @a.ede.dn5.dk AAAA network-error.nx.ede.dn5.dk
#
# It contains an EDE 13 (Cached Error) with the extra text “🔥🔥🔥”.
#
subtest 'Packet with EDE + UTF-8 text' => sub {
    my $p = Zonemaster::LDNS::Packet->new_from_wireformat(decode_base64(<<DATA));
6D+FAwABAAAAAAABDW5ldHdvcmstZXJyb3ICbngDZWRlA2RuNQJkawAAHAABAAApBNAAAAAAABIADw
AOABfwn5Sl8J+UpfCflKU=
DATA

    test_ede( $p, 23, '🔥🔥🔥' );
};

#
# This test packet was obtained by performing the following query:
#
# % dig +nord +nocookie @aphrodite.x0r.fr SOA blah.
#
# It contains an EDE 20 (Not Authoritative) with no extra text.
#

subtest 'Test packet with plain EDE' => sub {
    my $p = Zonemaster::LDNS::Packet->new_from_wireformat(decode_base64(<<DATA));
s5yABQABAAAAAAABBGJsYWgAAAYAAQAAKRAAAAAAAAAGAA8AAgAU
DATA

    test_ede( $p, 20, undef );
};

#
# Test setting an EDE in an existing packet.
#

subtest 'setting plain EDE in packet' => sub {
    my $p = Zonemaster::LDNS::Packet->new( 'test' );
    $p->qr(1);
    $p->aa(1);
    $p->opcode('QUERY');
    $p->rcode('REFUSED');

    test_ede( $p, undef, undef );

    is(
        exception { $p->ede(1) },
        undef,
        'Setting plain EDE doesn’t crash'
    );
    test_ede( $p, 1, undef );

    my $expected_wireformat = (<<DATA =~ s/ \s | \# [^\n]* \n //mgrx);
000084050001000000000001     # Header
04746573740000010001         # Question section: test./IN/A
00 0029 0000 00000000 0006   # Additional section: OPT pseudo-RR
000f 0002 0001               # EDNS option 15 (EDE), length and code 1
DATA

    is(
        unpack( 'H*', $p->wireformat() ),
        $expected_wireformat,
        'Packet contains only one instance of EDE'
    );
};

subtest 'setting EDE multiple times only keeps one instance of EDE' => sub {
    my $p = Zonemaster::LDNS::Packet->new( 'test' );
    $p->qr(1);
    $p->aa(1);
    $p->opcode('QUERY');
    $p->rcode('REFUSED');

    is(
        exception { $p->ede($_) for 1..4 },
        undef,
        'Setting plain EDE 4 times in a row doesn’t crash'
    );
    test_ede( $p, 4, undef );

    my $expected_wireformat = (<<DATA =~ s/ \s | \# [^\n]* \n //mgrx);
000084050001000000000001     # Header
04746573740000010001         # Question section: test./IN/A
00 0029 0000 00000000 0006   # Additional section: OPT pseudo-RR
000f 0002 0004               # EDNS option 15 (EDE), length and code 4
DATA

    is(
        unpack( 'H*', $p->wireformat() ),
        $expected_wireformat,
        'Packet contains only one instance of EDE'
    );
};

subtest 'setting EDE with extra text' => sub {
    my $p = Zonemaster::LDNS::Packet->new( 'test' );
    $p->qr(1);
    $p->aa(1);
    $p->opcode('QUERY');
    $p->rcode('REFUSED');

    is(
        exception { $p->ede(13, 'AXFR failed: REFUSED') },
        undef,
        'Setting EDE with text doesn’t crash'
    );
    test_ede( $p, 13, 'AXFR failed: REFUSED' );

    my $expected_wireformat = (<<DATA =~ s/ \s | \# [^\n]* \n //mgrx);
000084050001000000000001     # Header
04746573740000010001         # Question section: test./IN/A
00 0029 0000 00000000 001a   # Additional section: OPT pseudo-RR
000f 0016                    # EDNS option 15 (EDE) and length
000d 41584652206661696c65643a2052454655534544  # EDE code 13 and text
DATA

    is(
        unpack( 'H*', $p->wireformat() ),
        $expected_wireformat,
        'Packet contains only one instance of EDE'
    );
};

subtest 'setting EDE with UTF-8 text' => sub {
    my $p = Zonemaster::LDNS::Packet->new( 'test' );
    $p->qr(1);
    $p->aa(1);
    $p->opcode('QUERY');
    $p->rcode('REFUSED');

    my $backup = '🐈';
    my $extra_text = '🐈';

    is(
        exception { $p->ede(29, $extra_text) },
        undef,
        'Setting EDE with UTF-8 text doesn’t crash'
    );
    test_ede( $p, 29, $backup );

    is( $extra_text, $backup, 'Setting EDE has no ill side-effects on input variable' );

    my $expected_wireformat = (<<DATA =~ s/ \s | \# [^\n]* \n //mgrx);
000084050001000000000001     # Header
04746573740000010001         # Question section: test./IN/A
00 0029 0000 00000000 000a   # Additional section: OPT pseudo-RR
000f 0006                    # EDNS option 15 (EDE) and length
001d f09f9088                # EDE code 29 and cat emoji (U+1F408)
DATA

    is(
        unpack( 'H*', $p->wireformat() ),
        $expected_wireformat,
        'Packet contains only one instance of EDE'
    );
};

subtest 'setting EDE with null bytes in it' => sub {
    my $p = Zonemaster::LDNS::Packet->new( 'test' );
    $p->qr(1);
    $p->aa(1);
    $p->opcode('QUERY');
    $p->rcode('REFUSED');

    my $extra_text = "Messing\0with\0you\0";

    is(
        exception { $p->ede(65530, $extra_text) },
        undef,
        'Setting EDE with embedded null bytes doesn’t crash'
    );
    test_ede( $p, 65530, $extra_text );

    my $expected_wireformat = (<<DATA =~ s/ \s | \# [^\n]* \n //mgrx);
000084050001000000000001     # Header
04746573740000010001         # Question section: test./IN/A
00 0029 0000 00000000 0017   # Additional section: OPT pseudo-RR
000f 0013                    # EDNS option 15 (EDE) and length
fffa 4d657373696e67 00 77697468 00 796f75 00 # EDE code and string
DATA

    is(
        unpack( 'H*', $p->wireformat() ),
        $expected_wireformat,
        'Packet’s wireformat is correct'
    );
};

done_testing;
