use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => 'Net::LDNS',
    VERSION_FROM => 'lib/Net/LDNS.pm',
    LIBS => [qw(-lldns)],
    PREREQ_PM => {
        'MIME::Base64' => 0,
    },
    TEST_REQUIRES => {
        'JSON::XS' => 0,
    },
);