#!/usr/bin/env perl

use 5.018;
use strict;
use warnings;
use Find::Lib "./lib";
use JSON;
use Engine::Fuzzer;
use Functions::Helper;
use Parallel::ForkManager;
use Getopt::Long qw(:config no_ignore_case);

sub fuzzer_thread {
    my ($endpoint, $methods, $agent, $headers, $accept, $timeout, $return, $payload, $json, $delay, $exclude) = @_;
        
    my @verbs = split (/,/, $methods);
    my @valid_codes = split /,/, $return || "";
    my @invalid_codes = split /,/, $exclude || "";
        
    for my $verb (@verbs) {
        my $result = Engine::Fuzzer -> new ($agent, $timeout, $headers, $endpoint, $verb, $payload, $accept);

        my $status = $result -> {Code};
        next if grep(/^$status$/, @invalid_codes) || ($return && !grep(/^$status$/, @valid_codes));
            
        my $printable = $json ? encode_json($result) : sprintf(
            "Code: %d | URL: %s | Method: %s | Response: %s | Length: %s",
            $status, $result -> {URL}, $result -> {Method},
            $result -> {Response}, $result -> {Length}
        );

        print $printable, "\n";
        sleep($delay);
    }
}

sub main {
    my ($target, $return, $payload, %headers, $accept, $json, $exclude);
    my $agent    = "Nozaki CLI / 0.2.3";
    my $delay    = 0;
    my $timeout  = 10;
    my $wordlist = "wordlists/default.txt";
    my $methods  = "GET,POST,PUT,DELETE,HEAD,OPTIONS,TRACE,PATCH,PUSH";
    my $tasks    = 10;

    Getopt::Long::GetOptions (
        "A|accept=s"   => \$accept,
        "u|url=s"      => \$target,
        "w|wordlist=s" => \$wordlist,
        "m|method=s"   => \$methods,
        "d|delay=i"    => \$delay,
        "t|timeout=i"  => \$timeout,
        "a|agent=s"    => \$agent,
        "r|return=s"   => \$return,
        "p|payload=s"  => \$payload,
        "j|json"       => \$json,
        "H|header=s%"  => \%headers,
        "T|tasks=i"    => \$tasks,
        "e|exclude=s"  => \$exclude,
    );
        
    if ($target) {
        my @resources;
        
        for my $list (glob($wordlist)) {
            open (my $file, "<$list") || die "$0: Can't open $list";

            while (<$file>) {
                chomp ($_);
                push @resources, $_;
            }

            close ($file);
        }

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

    return Functions::Helper -> new();
} 

main();
exit;