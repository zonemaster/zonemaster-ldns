use inc::Module::Install;
use Devel::CheckLib;
use Getopt::Long;
use File::Spec::Functions;

BEGIN {
    if ($Module::Install::AUTHOR) {
        use Module::Install::XSUtil;
    }
}

my $headdir;
my $libdir;
my $prefix;

GetOptions(
    'headers=s' => \$headdir,
    'libs=s' => \$libdir,
    'prefix=s' => \$prefix,
);

if ($prefix) {
    $headdir = catdir($prefix, 'include');
    $libdir = catdir($prefix, 'lib');
}

cc_include_paths($headdir) if $headdir;
cc_libs('-L' . $libdir) if $libdir;

name 'Net-LDNS';
version_from 'lib/Net/LDNS.pm';
license 'bsd';
author 'Calle Dybedahl <calle@init.se>';
abstract 'Perl wrapper for the ldns DNS library.';
perl_version '5.010001';

configure_requires 'Devel::CheckLib';
requires 'MIME::Base64';
test_requires 'JSON::PP';
test_requires 'Test::Fatal';

use_ppport 3.19;
cc_libs 'ldns';
cc_src_paths 'src';
cc_assert_lib lib => 'ldns', header => 'ldns/ldns.h', function => 'if(atof(ldns_version())>=1.6) return 0; else return 1;';

if (check_lib(lib => 'idn', header => 'idna.h', function => 'if(strcmp(IDNA_ACE_PREFIX,"xn--")==0) return 0; else return 1;'))
{
    cc_libs 'idn';
    cc_define '-DWE_CAN_HAZ_IDN';
}

WriteAll;
