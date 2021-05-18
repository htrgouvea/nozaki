#!/usr/bin/env perl

use 5.018;
use strict;
use threads;
use warnings;
use Thread::Queue;
use Find::Lib "./lib";
use Functions::Helper;
use Functions::Parser;
use Engine::Orchestrator;
use Getopt::Long qw(:config bundling pass_through);

sub main {
    my ($workflow, $target);

    Getopt::Long::GetOptions (
        "W|workflow=s" => \$workflow,
        "u|url=s"      => \$target
    );

    if ($workflow) {
        my $rules = Functions::Parser -> new($workflow);

        for my $rule (@$rules) {
            delete $rule -> {description};
            
            my $args = [ map { "--$_" . ($rule -> {$_} ? "=$rule->{$_}" : "") } keys %{$rule} ];
            return Engine::Orchestrator -> run_fuzzer($target, $args);
        }
    }

    if ($target)  {
        return Engine::Orchestrator -> run_fuzzer ($target, \@ARGV);
    }

    return Functions::Helper -> new();
} 

exit main();