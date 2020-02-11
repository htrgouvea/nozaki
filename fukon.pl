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
    my ($target, $wordlist, $return, $exclude, $threads);

    GetOptions (
        "--url=s"      => \$target,
        "--wordlist=s" => \$wordlist,
        "--return=s"   => \$return,
        "--exclude=s"  => \$exclude,
        "--threads=i"  => \$threads,
        "--help"       => sub { 
            Functions::Helper -> new();
        }
    );
    
    if ($target) {
        if (!$wordlist) {
            $wordlist = "wordlists/default.txt";
        }

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