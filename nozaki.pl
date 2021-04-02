#!/usr/bin/env perl

use 5.018;
use strict;
use warnings;
use Find::Lib "./lib";
use JSON;
use Engine::Fuzzer;
use Functions::Helper;
use Functions::Parser;
use Parallel::ForkManager;
use Getopt::Long qw(:config no_ignore_case pass_through);

sub fuzzer_thread {
    my (
        $endpoint, $methods, $agent, $headers, $accept, $timeout, $return, $payload, $json, $delay, $exclude, $skipssl
    ) = @_;
        
    my @verbs = split (/,/, $methods);
    my @valid_codes = split /,/, $return || "";
    my @invalid_codes = split /,/, $exclude || "";
        
    for my $verb (@verbs) {
        my $result = Engine::Fuzzer -> new ($agent, $timeout, $headers, $endpoint, $verb, $payload, $accept, $skipssl);

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

sub run_fuzzer {
    my ($args, $target) = @_;
    my ($return, $payload, %headers, $accept, $json, $exclude, $skipssl);
    my $agent    = "Nozaki CLI / 0.2.3";
    my $delay    = 0;
    my $timeout  = 10;
    my $wordlist = "wordlists/default.txt";
    my $methods  = "GET,POST,PUT,DELETE,HEAD,OPTIONS,TRACE,PATCH,PUSH";
    my $tasks    = 10;

    Getopt::Long::GetOptionsFromArray (
        $args,
        "A|accept=s"   => \$accept,
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
        "S|skip-ssl"   => \$skipssl,
    );
    
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
            
        fuzzer_thread($endpoint, $methods, $agent, \%headers, $accept, $timeout, $return, $payload, $json, $delay, $exclude, $skipssl);
            
        $threadmgr -> finish();
    }

    $threadmgr -> wait_all_children();

    return 0;

}

sub main {
    my ($workflow, $target, $help);
    
    Getopt::Long::GetOptions (
        "workflow=s" => \$workflow,
        "u|url=s"    => \$target,
        "h|help"     => \$help
    );

    return Functions::Helper -> new() if $help;

    die "No target specified" unless $target;

    if ($workflow)
    {
        my $rules = Functions::Parser -> new($workflow);
        for my $rule (@$rules)
        {
            delete $rule->{description};
            my $args = [ map { "--$_" . ($rule->{$_} ? "=$rule->{$_}" : "") } keys %{$rule} ];
            run_fuzzer($args, $target);
        }
    }
    else
    {
        run_fuzzer(\@ARGV, $target);
    }

    return 0;
} 

exit main();