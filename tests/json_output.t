#!/usr/bin/env perl
use strict;
use warnings;
use JSON;
use Test::More;
use Test::MockModule;
use File::Temp qw/ tempfile /;

use lib '../lib/';

my ($fh, $wordlist_filename) = tempfile();
print $fh "/test1\n/test2\n/test3\n";
close $fh;

ok(-e $wordlist_filename, "Wordlist file exists before execution");

my $mock_multi_result = [
    {
        Method   => "GET",
        URL      => "http://example.com/test1",
        Length   => "1024",
        Code     => "200",
        Content  => "Sample content 1",
        Response => "OK"
    },
    {
        Method   => "POST",
        URL      => "http://example.com/test2",
        Length   => "512",
        Code     => "404",
        Content  => "Not found",
        Response => "Not Found"
    },
    {
        Method   => "PUT",
        URL      => "http://example.com/test3",
        Length   => "256",
        Code     => "403",
        Content  => "Forbidden",
        Response => "Forbidden"
    }
];

my $mock_helper = Test::MockModule->new('Functions::Helper');
$mock_helper->mock('new', sub { return $wordlist_filename });

sub test_multiple_items_json {
    my $mock_fuzzer = Test::MockModule->new('Engine::FuzzerThread');
    $mock_fuzzer->mock('new', sub { return bless {}, 'Engine::FuzzerThread' });
    $mock_fuzzer->mock('run', sub { return $mock_multi_result });

    my $json_output;
    my $decoded_json;
    my $debug_log = "debug.log";

    for (1..5) { 
        $json_output = `$^X ../nozaki.pl -j -u http://example.com/ -w $wordlist_filename 2>/dev/null`;
        
        open my $log, '>', $debug_log;
        print $log $json_output;
        close $log;
        
        eval { $decoded_json = decode_json($json_output) };
        last unless $@;
        
        sleep 1; 
    }

    ok(!$@, "Multiple items JSON is valid") or diag "Decoding error: $@";
    cmp_ok(scalar @$decoded_json, '>', 1, "Multiple items array contains more than one element");

    foreach my $result (@$decoded_json) {
        ok(exists $result->{Method}, "Result has Method");
        ok(exists $result->{URL}, "Result has URL");
        ok(exists $result->{Length}, "Result has Length");
        ok(exists $result->{Code}, "Result has Code");
        ok(exists $result->{Content}, "Result has Content");
        ok(exists $result->{Response}, "Result has Response");
    }

    return;
}

test_multiple_items_json();

END { 
    unlink $wordlist_filename if $wordlist_filename; 
    unlink "debug.log" if -e "debug.log"; 
}

done_testing();
