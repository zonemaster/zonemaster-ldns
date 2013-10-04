use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => 'NetLDNS',
    VERSION_FROM => 'lib/NetLDNS.pm',
    OBJECT => 'NetLDNS.o ldns_glue.o',
    LIBS => [qw(-lldns)],
);