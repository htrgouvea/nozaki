#!/usr/bin/env perl

use JSON;
use 5.018;
use strict;
use warnings;
use lib "./lib/";
use Engine::Fuzzer;
use Functions::Helper;
use Parallel::ForkManager;
use Getopt::Long qw(:config no_ignore_case);

sub fuzzer_thread {
    my ($endpoint, $methods, $agent, $headers, $accept, $timeout, $return, $payload, $json, $delay, $exclude) = @_;
    
    my $fuzzer = Engine::Fuzzer -> new (
            useragent => $agent,
            timeout => $timeout,
            headers => $headers
    );
    
    my @verbs = split (/,/, $methods);

    for my $verb (@verbs) {
        my $result = $fuzzer -> fuzz ($endpoint, $verb, $payload, $accept);

        next if ($return && $return != $result -> {Code}) || ($exclude && $exclude == $result -> {Code});

        my $printable = $json ? encode_json($result) : sprintf(
            "Code: %d | URL: %s | Method: %s | Response: %s | Length: %s",
            $result -> {Code}, $result -> {URL}, $result -> {Method},
            $result -> {Response}, $result -> {Length}
        );

        print $printable . "\n";
        sleep($delay);
    }
}

sub main {
    my ($target, $return, $payload, %headers, $accept, $json, $exclude);
    my $agent    = "Nozaki CLI / 0.2.1";
    my $delay    = 0;
    my $timeout  = 10;
    my $wordlist = "wordlists/default.txt";
    my $methods  = "GET,POST,PUT,DELETE,HEAD,OPTIONS,TRACE,PATCH,PUSH";
    my $tasks    = 10;

    GetOptions (
        "A|accept=s"   => \$accept,
        "u|url=s"      => \$target,
        "w|wordlist=s" => \$wordlist,
        "m|method=s"   => \$methods,
        "d|delay=i"    => \$delay,
        "t|timeout=i"  => \$timeout,
        "a|agent=s"    => \$agent,
        "r|return=i"   => \$return,
        "p|payload=s"  => \$payload,
        "j|json"       => \$json,
        "H|header=s%"  => \%headers,
        "T|tasks=i"    => \$tasks,
        "e|exclude=s"  => \$exclude,
    ) or die ( return Functions::Helper -> new() );

    return Functions::Helper -> new() unless $target && $wordlist;
    
    open (my $file, "<", $wordlist) || die "$0: Can't open $wordlist";
    
    my @resources;

    while (<$file>) {
        chomp ($_);
        push @resources, $_;
    }

    close ($file);

    my $threadmgr = Parallel::ForkManager -> new($tasks);

    $threadmgr -> set_waitpid_blocking_sleep(0);
    THREADS:

    for (@resources) {
        my $endpoint = $target . $_;
        $threadmgr -> start() and next THREADS;
        
        fuzzer_thread($endpoint, $methods, $agent, \%headers, $accept, $timeout, $return, $payload, $json, $delay, $exclude);
        
        $threadmgr -> finish();
    }

    $threadmgr -> wait_all_children();

    return 0;
}

exit main();