use Test::More;

use_ok('Net::LDNS');

my $can_use_threads = eval 'use threads; 1';
if ($can_use_threads) {
    my $resolver = Net::LDNS->new('8.8.8.8');
    threads->create( sub {} );
    $_->join for threads->list;
} else {
    plan skip_all => 'No threads in this perl.';
}


done_testing;