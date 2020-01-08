#!/usr/bin/env perl

use 5.018;
use strict;
use warnings;
use lib "./lib/";
use Fuzzers::Param;
use Fuzzers::Method;
use Fuzzers::ContentType;

sub main {
    my $target   = $ARGV[0];
    my $wordlist = $ARGV[1];

    if (!$wordlist) {
        $wordlist = "wordlists/default.txt";
    }

    if ($target) {
        open (my $file, "<", $wordlist);

        while (<$file>) {
            chomp ($_);
        
            my $fuzzMethod = Fuzzers::Method -> new("$target/$_");
        }

        close ($file);
    }
}

main();
exit;
