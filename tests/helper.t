use strict;
use warnings;
use Test::More tests => 2;
use Capture::Tiny ':all';
use lib 'lib';
use Functions::Helper;

my $output = capture_stdout {
    my $result = Functions::Helper::new();
    is($result, 0, 'new() should return 0');
};

like($output, qr/Nozaki v0/, 'Output should contain Nozaki version');