#!/usr/bin/env perl

use 5.018;
use strict;
use warnings;
use Getopt::Long;
use lib "./lib/";
use Fuzzers::Param;
use Fuzzers::Method;
use Fuzzers::ContentType;
use Functions::Helper;
use Functions::Filter;

sub main {
    # implement -> my ($method, $contentType, $param, $verbose);
    my ($target, $wordlist, $return, $exclude, $threads, $help);

    GetOptions (
        "--url=s"      => \$target,
        "--wordlist=s" => \$wordlist,
        "--return=s"   => \$return,
        "--exclude=s"  => \$exclude,
        "--threads=i"  => \$threads,
        "--help"       => \$help,
    );

    if ($help) {
        Functions::Helper -> new();
    }

    if (!$wordlist) {
        $wordlist = "wordlists/default.txt";
    }

    if ($target) {
        # $target =~ s/https:\/\/// || $target =~ s/http:\/\///;
        open (my $file, "<", $wordlist);

        while (<$file>) {
            chomp ($_);

            if (($return) || ($exclude)) {
                my %fuzzFilter = Functions::Filter -> new($return, $exclude);

                my $fuzzMethod = Fuzzers::Method -> new(
                    "$target/$_", 
                    $fuzzFilter{return}, 
                    $fuzzFilter{exclude}
                );
            }

            else {
                my $fuzzMethod = Fuzzers::Method -> new($target . $_);
            }
        }

        close ($file);
    }
}

main();