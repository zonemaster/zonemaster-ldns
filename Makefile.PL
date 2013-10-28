use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => 'Net::LDNS',
    VERSION_FROM => 'lib/Net/LDNS.pm',
    LIBS => [qw(-lldns)],
);