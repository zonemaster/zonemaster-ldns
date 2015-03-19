use Test::More;

use_ok('Net::LDNS');

my $can_use_threads = eval 'use threads; 1';
if ($can_use_threads) {

    my $resolver = Net::LDNS->new('8.8.8.8');
    my $rr = Net::LDNS::RR->new('www.iis.se.		60	IN	A	91.226.36.46');
    threads->create( sub {} );
    $_->join for threads->list;

} else {
    plan skip_all => 'No threads in this perl.';
}


done_testing;