use Test::More;

BEGIN { use_ok('Net::LDNS');}

my $key1 = Net::LDNS::RR->new("iis.se.	2395	IN	DNSKEY	257 3 5 AwEAAcq5u+qe5VibnyvSnGU20panweAk2QxflGVuVQhzQABQV4SIdAQs +LNVHF61lcxe504jhPmjeQ656X6t+dHpRz1DdPO/ukcIITjIRoJHqS+X XyL6gUluZoDU+K6vpxkGJx5m5n4boRTKCTUAR/9rw2+IQRRTtb6nBwsC 3pmf9IlJQjQMb1cQTb0UO7fYgXDZIYVul2LwGpKRrMJ6Ul1nepkSxTMw Q4H9iKE9FhqPeIpzU9dnXGtJ+ZCx9tWSZ9VsSLWBJtUwoE6ZfIoF1ioq qxfGl9JV1/6GkDxo3pMN2edhkp8aqoo/R+mrJYi0vE8jbXvhZ12151Dy wuSxbGjAlxk=");
my $key2 = Net::LDNS::RR->new("iis.se.	1591	IN	DNSKEY	256 3 5 BQEAAAABuWpCewwMRD7yPzy6TGsymMAc82IHVGB+vjKVIAYKbPG7QxuLEtEzUxDJo09gLN2/N0OF+NnTkmDMj8KA+eIgtqmMuq5kdDVc+eSNLJZ0 am0o27UEkXmW20iV0d6B/KW1X1nufzBSaacUzkBKyDfK4cN3aVsYIDXT H7Jw1agEzrM=");
my $soa  = Net::LDNS::RR->new("iis.se.	3600	IN	SOA	ns.nic.se. hostmaster.iis.se. 1384853101 10800 3600 1814400 14400");
my $sig  = Net::LDNS::RR->new("iis.se.	3600	IN	RRSIG	SOA 5 2 3600 20131129082501 20131119082501 59213 iis.se. ShhhfRT82jfA/J1AAqiie/4r7JuiYOpK6dIwugOtlf0/UpVsOYEIukpe Bq9i7fsa0GNWz/o9gqF8DnsCHzgxZnAngTrJpZAlsrC/FP/6v8WfnFsP LDw9g6Ow8Z6TL9JmZr22YPp27Rwujdb5AnzdurEvQxIAqW66CCCy2pc9 //s=");

# isa_ok($key1, 'Net::LDNS::RR::DNSKEY');
# isa_ok($key2, 'Net::LDNS::RR::DNSKEY');
# isa_ok($soa, 'Net::LDNS::RR::SOA');
# isa_ok($sig, 'Net::LDNS::RR::RRSIG');
# 
is($sig->keytag, $key2->keytag);

ok($sig->verify([$soa], [$key1, $key2]), 'Signature verifies.');
ok(!$sig->verify([$soa], [$key1]), 'Signature does not verify.');

is($sig->verify_str([$soa], [$key1, $key2]), 'All OK', 'Expected successful verification message.');
is($sig->verify_str([$soa], [$key1]), 'No keys with the keytag and algorithm from the RRSIG found', 'Expected unsuccessful verification message.');

my $ds1 = $key1->ds('sha1');
isa_ok($ds1, 'Net::LDNS::RR::DS','sha1');
ok($ds1->verify($key1)) if $ds1;

my $ds2 = $key1->ds('sha256');
isa_ok($ds2, 'Net::LDNS::RR::DS','sha256');
ok($ds2->verify($key1)) if $ds2;

my $ds3 = $key1->ds('sha384');
isa_ok($ds3, 'Net::LDNS::RR::DS','sha384');
ok($ds3->verify($key1)) if $ds3;

my $ds4 = $key1->ds('gost');
if ($ds4) { # We may not have GOST available.
    isa_ok($ds4, 'Net::LDNS::RR::DS','gost');
    ok($ds4->verify($key1)) if $ds4;
}

done_testing;