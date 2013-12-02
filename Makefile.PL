use inc::Module::Install;

name 'Net-LDNS';
version_from 'lib/Net/LDNS.pm';
license 'bsd';
author 'Calle Dybedahl <calle@init.se>';
abstract 'Perl wrapper for the ldns DNS library.';
perl_version '5.012004';

requires 'MIME::Base64';
test_requires 'JSON::XS';

use_ppport 3.19;
cc_libs 'ldns';
cc_src_paths 'src';
cc_assert_lib lib => 'ldns', header => 'ldns/ldns.h';

WriteAll;
