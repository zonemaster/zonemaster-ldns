package NetLDNS;

our $VERSION = '0.1';
require XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

use NetLDNS::RR;

1;