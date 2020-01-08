#!/usr/bin/env perl

use 5.018;
use strict;
use warnings;
use Getopt::Long;
use lib "./lib/";
use Helper;
use Fuzzers::Param;
use Fuzzers::Method;
use Fuzzers::ContentType;

sub main {
    my ($threads, $target, $wordlist, $verbose, $help);

    GetOptions (
        "--threads=i"  => \$threads,
        "--url=s"      => \$target,
        "--wordlist=s" => \$wordlist,
        "--verbose"    => \$verbose,
        "--help"       => \$help,   
    );   

    if ($help) {
        Helper -> new();
    }

    if (!$wordlist) {
        $wordlist = "wordlists/default.txt";
    }

    if ($target) {
        open (my $file, "<", $wordlist);

        while (<$file>) {
            chomp ($_);
        
            my $fuzzMethod = Fuzzers::Method -> new($target . $_);
        }

        close ($file);
    }
}

main();
exit;
