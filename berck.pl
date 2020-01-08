#!/usr/bin/env perl

use 5.018;
use strict;
use warnings;
use lib "./lib/";
use MethodFuzzer;

sub main {
    my $target   = $ARGV[0];
    my $wordlist = "wordlists/default.txt";

    if ($target) {
        open (my $file, "<", $wordlist);

        while (<$file>) {
            chomp ($_);
        
            my $fuzzMethod = MethodFuzzer -> new("$target/$_");
        }

        close ($file);
    }
}

main();
exit;
