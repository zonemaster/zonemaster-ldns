package Net::LDNS;

our $VERSION = '0.1';
require XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

use Net::LDNS::RR;

1;