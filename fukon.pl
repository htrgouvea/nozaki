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
    my (
        $target, $wordlist, $header, $threads, $param, $mimeType, $method, $payload, $return, $exclude, $json
    );

    GetOptions (
        "--url=s"      => \$target,
        "--wordlist=s" => \$wordlist,
        "--header=s"   => \$header,
        "--threads=i"  => \$threads,
        "--param"      => \$param,
        "--mime-type"  => \$mimeType,
        "--method=s"   => \$method,
        "--payload=s"  => \$payload,
        "--return=s"   => \$return,
        "--exclude=s"  => \$exclude,
        "--json=s"     => \$json
    ) or die (
        return Functions::Helper -> new()
    );
    
    if ($target) {
        if (!$wordlist) {
            $wordlist = "wordlists/default.txt";
        }

        if (!$header) {
            $header = [
                "Accept" => "*/*",
                "Content-Type" => "*/*"
            ];
        }

        open (my $file, "<", $wordlist);

        while (<$file>) {
            chomp ($_);
            my $endpoint = $target.$_;

            my $fuzzer = Fuzzers::Method -> new(
                $endpoint,
                $header
            );
        }

        close ($file);
        return 1;
    }

    return Functions::Helper -> new();
}

main();