use inc::Module::Install;

name 'Net-LDNS';
version_from 'lib/Net/LDNS.pm';
license 'bsd';

requires perl => '5.012004';
requires 'MIME::Base64';
test_requires 'JSON::XS';

use_ppport 3.20;
cc_libs 'ldns';
cc_src_paths 'src';

WriteAll;