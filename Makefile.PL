use inc::Module::Install;

BEGIN {
    if ($Module::Install::AUTHOR) {
        use Module::Install::XSUtil;
    }
}

name 'Net-LDNS';
version_from 'lib/Net/LDNS.pm';
license 'bsd';
author 'Calle Dybedahl <calle@init.se>';
abstract 'Perl wrapper for the ldns DNS library.';
perl_version '5.012004';

requires 'MIME::Base64';
test_requires 'JSON::XS';
test_requires 'Test::Fatal';

use_ppport 3.19;
cc_libs 'ldns';
cc_src_paths 'src';
cc_assert_lib lib => 'ldns', header => 'ldns/ldns.h', function => 'if(atof(ldns_version())>=1.6) return 0; else return 1;';

WriteAll;
