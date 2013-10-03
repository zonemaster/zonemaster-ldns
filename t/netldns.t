use Test::More;

BEGIN { use_ok('NetLDNS')}

is(NetLDNS::seventeen(), 17);

done_testing;