#!/usr/bin/env perl

use 5.018;
use strict;
use threads;
use warnings;
use Thread::Queue;
use Find::Lib "./lib";
use Functions::Helper;
use Functions::Parser;
use Engine::FuzzerThread;
use Engine::Orchestrator;
use Getopt::Long qw(:config bundling pass_through);

sub main {
    my ($workflow, $target, $accept, $return, $payload, %headers, $json, $exclude, $skipssl);
    my $agent    = "Nozaki / 0.2.4";
    my $delay    = 0;
    my $timeout  = 10;
    my $wordlist = "wordlists/default.txt";
    my $methods  = "GET,POST,PUT,DELETE,HEAD,OPTIONS";
    my $tasks    = 10;

    Getopt::Long::GetOptionsFromArray (
        \@ARGV,
        "W|workflow=s" => \$workflow,
        "u|url=s"      => \$target,
        "A|accept=s"   => \$accept,
        "w|wordlist=s" => \$wordlist,
        "m|method=s"   => \$methods,
        "d|delay=i"    => \$delay,
        "t|timeout=i"  => \$timeout,
        "a|agent=s"    => \$agent,
        "r|return=s"   => \$return,
        "p|payload=s"  => \$payload,
        "H|header=s%"  => \%headers,
        "j|json"       => \$json,
        "T|tasks=i"    => \$tasks,
        "e|exclude=s"  => \$exclude,
        "S|skip-ssl"   => \$skipssl,
    );

    if ($workflow) {
        my $rules = Functions::Parser -> new($workflow);
        
        for my $rule (@$rules) {
            delete $rule -> {description};

            my $args = [ map { "--$_" . ($rule -> {$_} ? "=$rule->{$_}" : "") } keys %{$rule} ];

            use Data::Dumper;
            print Dumper($args);

            return Engine::Orchestrator -> run_fuzzer($target, $args);
        }
    }

    if ($target)  {
        return Engine::Orchestrator -> run_fuzzer (
            $target, $tasks, $return, $payload, $accept, $json, $exclude, $skipssl, $wordlist, $methods, $agent, $timeout, $delay, %headers
        );
    }

    return Functions::Helper -> new();
} 

exit main();