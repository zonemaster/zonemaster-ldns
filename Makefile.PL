use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => 'NetLDNS',
    VERSION_FROM => 'lib/NetLDNS.pm',
    LIBS => [qw(-lldns)],
);