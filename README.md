This module aims to provide a Perlish interface to the ldns library from NLnet Labs (https://www.nlnetlabs.nl/projects/ldns/). As such, that library needs to be installed for the module to build (and, obviously, work).

While the long-term goal is of course to provide a full interface to the library, as of this writing (November 2013) priority is given to those parts of the library that we need for another project. This explains, for example, the relatively small number of RR types that are currently supported. If you want to use this library and need not yet implemented parts, please log a ticket. If nothing else it will let us know where interest lies.

Installation uses the normal `perl Makefile.PL && make && make test && make install` sequence. This assumes that `ldns` can be found in one of the places where the C compiler looks by default. `make test` assumes that it can send queries to the outside world.

/Calle Dybedahl <calle@init.se>, 2013-11-14