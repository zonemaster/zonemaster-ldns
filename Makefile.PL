use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => 'NetLDNS',
    VERSION_FROM => 'lib/NetLDNS.pm',
    OBJECT => 'NetLDNS.o seventeen.o',
);