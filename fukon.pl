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
    # implement -> my ($method, $contentType, $param);
    my ($target, $wordlist, $return, $threads, $verbose, $help);

    GetOptions (
        "--url=s"          => \$target,
        "--wordlist=s"     => \$wordlist,
        "--return=s"       => \$return,
        # "--threads=i"    => \$threads,
        # "--method"       => \$method,
        # "--content-type" => \$contentType,
        # "--param"        => \$param,
        # "--verbose"      => \$verbose,
        "--help"           => \$help,
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

            if ($return) {
                my @return  = split(/,/, $return);
                my $fuzzMethod = Fuzzers::Method -> new($target . $_, @return);
            }

            else {
                my $fuzzMethod = Fuzzers::Method -> new($target . $_);
            }
        }

        close ($file);
    }
}

main();