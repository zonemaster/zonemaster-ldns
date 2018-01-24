use inc::Module::Install;
use Devel::CheckLib;
use Getopt::Long;
use File::Spec::Functions;

BEGIN {
    if ( $Module::Install::AUTHOR ) {
        use Module::Install::XSUtil;
    }
}

my $headdir;
my $libdir;
my $prefix;
my $randomize;

GetOptions(
    'headers=s'  => \$headdir,
    'libs=s'     => \$libdir,
    'prefix=s'   => \$prefix,
    'randomize!' => \$randomize,
);

if ( $prefix ) {
    $headdir = catdir( $prefix, 'ldns' );
    $libdir  = catdir( $prefix, 'lib' );
}

cc_include_paths( $headdir ) if $headdir;
cc_libs( '-L' . $libdir ) if $libdir;

cc_include_paths( 'include' );
cc_include_paths( 'ldns' );

name 'Zonemaster-LDNS';
version_from 'lib/Zonemaster/LDNS.pm';
perl_version_from 'lib/Zonemaster/LDNS.pm';
license 'bsd';
author 'Calle Dybedahl <calle@init.se>';
author 'Mattias P <mattias.paivarinta@iis.se>';
abstract 'Perl wrapper for the ldns DNS library.';
repository 'https://github.com/dotse/zonemaster-ldns';
bugtracker 'https://github.com/dotse/zonemaster-ldns/issues';

configure_requires 'Devel::CheckLib';
requires 'MIME::Base64';
test_requires 'JSON::PP';
test_requires 'Test::Fatal';

use_ppport 3.19;
cc_libs 'crypto';
cc_src_paths 'src';
cc_libs( '-Lldns/lib' );

my %assert_args = (
    lib      => 'crypto',
    header   => 'openssl/crypto.h',
    function => 'if(SSLeay()) return 0; else return 1;'
);
$assert_args{LIBS} = '-L' . $libdir  if $libdir;
$assert_args{INC}  = '-I' . $headdir if $headdir;

cc_assert_lib %assert_args;

if (
    check_lib(
        lib      => 'idn',
        header   => 'idna.h',
        function => 'if(strcmp(IDNA_ACE_PREFIX,"xn--")==0) return 0; else return 1;'
    )
  )
{
    cc_libs 'idn';
    cc_define '-DWE_CAN_HAZ_IDN';
    print "IDNA support detected.\n";
}

if ( $randomize ) {
    cc_define '-DRANDOMIZE';
    print( ( "=" x 65 ) . "\n" );
    print "Compiling with randomzied capitalization.\n";
    print( ( "=" x 65 ) . "\n" );
}

sub MY::postamble {
    return <<'TARGET';

LDFROM += ldns/.libs/libldns.a

config :: ldns/.libs/libldns.a

ldns/.libs/libldns.a: ldns/configure
	cd ldns ;\
	./configure CFLAGS=-fPIC --disable-ldns-config --disable-dane ;\
	make lib

ldns/configure:
	git submodule update --init
	cd ldns ; libtoolize -ci
	cd ldns ; autoreconf -fi

CONTRIBUTORS.txt:
	@( \
	echo "This module is based on the ldns library from NLnet Labs <https://www.nlnetlabs.nl/projects/ldns/>" ; \
    echo ; \
	echo "Contributors to this module:" ; \
	git shortlog -sne | cut -b8- \
	) >| CONTRIBUTORS.txt

TARGET
}

WriteAll;
