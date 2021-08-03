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
use Getopt::Long qw(:config no_ignore_case);

sub main {
    my ($workflow, $plugin);
    my %options = (
        accept   => "*/*", 
        wordlist => "wordlists/default.txt",
        method   => "GET,POST,PUT,DELETE,HEAD,OPTIONS,TRACE,PATCH,PUSH",
        headers  => {},
        timeout  => 10,
        agent    => "Nozaki / 0.2.5",
        tasks    => 10,
        delay    => 0,
    );

    Getopt::Long::GetOptions (
        "W|workflow=s" => \$workflow,
        "u|url=s"      => \$options{target},
        "A|accept=s"   => \$options{accept},
        "w|wordlist=s" => \$options{wordlist},
        "m|method=s"   => \$options{method},
        "d|delay=i"    => \$options{delay},
        "t|timeout=i"  => \$options{timeout},
        "a|agent=s"    => \$options{agent},
        "r|return=s"   => \$options{return},
        "p|payload=s"  => \$options{payload},
        "j|json"       => \$options{json},
        "H|header=s%"  =>  $options{headers},
        "T|tasks=i"    => \$options{tasks},
        "e|exclude=s"  => \$options{exclude},
        "S|skip-ssl"   => \$options{skipssl},
        "l|length=s"   => \$options{length},
        "p|plugin=s"   => \$options{plugin},
    );

    return Functions::Helper -> new() unless $options{target};

    if ($workflow) {
        my $rules = Functions::Parser -> new($workflow);

        for my $rule (@$rules) {
            my %new_options = %options;
            map { $new_options{$_} = $rule -> {$_} || 1 } keys %{$rule};

            Engine::Orchestrator -> run_fuzzer(%new_options);
        }

        return 0;
    }

    return Engine::Orchestrator -> run_fuzzer (%options);
} 

exit main() unless caller;