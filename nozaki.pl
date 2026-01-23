#!/usr/bin/env perl
use 5.030;
use strict;
use threads;
use warnings;
use Thread::Queue;
use Find::Lib './lib';
use Functions::Helper;
use Functions::Parser;
use Engine::Orchestrator;
use Getopt::Long qw(:config no_ignore_case);

our $VERSION = '0.3.1';

sub main {
    my ($workflow_path, @targets);

    my %fuzzer_options = (
        accept   => '*/*',
        wordlist => 'wordlists/default.txt',
        method   => 'GET,POST,PUT,DELETE,HEAD,OPTIONS,PATCH,PUSH',
        headers  => {},
        timeout  => 10,
        agent    => 'Nozaki / 0.3.1',
        tasks    => 35,
        delay    => 0
    );

    Getopt::Long::GetOptions (
        'A|accept=s'              => \$fuzzer_options{accept},
        'a|agent=s'               => \$fuzzer_options{agent},
        'c|content=s'             => \$fuzzer_options{content},
        'd|delay=i'               => \$fuzzer_options{delay},
        'e|exclude=s'             => \$fuzzer_options{exclude},
        'H|header=s%'             => \$fuzzer_options{headers},
        'w|wordlist=s'            => \$fuzzer_options{wordlist},
        'W|workflow=s'            => \$workflow_path,
        'm|method=s'              => \$fuzzer_options{method},
        'r|return=s'              => \$fuzzer_options{return},
        'p|payload=s'             => \$fuzzer_options{payload},
        'j|json'                  => \$fuzzer_options{json},
        'S|skip-ssl'              => \$fuzzer_options{skipssl},
        'T|tasks=i'               => \$fuzzer_options{tasks},
        't|timeout=i'             => \$fuzzer_options{timeout},
        'u|url=s@'                => \@targets,
        'l|length=s'              => \$fuzzer_options{length},
        'C|filter-content-type=s' => \$fuzzer_options{content_type},
        'P|proxy=s'               => \$fuzzer_options{proxy}
    );

    if (!@targets) {
        return Functions::Helper -> new();
    }

    if ($workflow_path) {
        my $rules = Functions::Parser -> new($workflow_path);

        for my $rule (@$rules) {
            my %workflow_options = %fuzzer_options;

            Engine::Orchestrator::add_target(@targets);

            for my $rule_key (keys %{$rule}) {
                my $rule_value = $rule -> {$rule_key};

                if ($rule_value) {
                    $workflow_options{$rule_key} = $rule_value;
                }

                if (!$rule_value) {
                    $workflow_options{$rule_key} = 1;
                }
            }

            Engine::Orchestrator -> run_fuzzer(%workflow_options);
        }

        return 0;
    }

    Engine::Orchestrator::add_target(@targets);

    return Engine::Orchestrator -> run_fuzzer(%fuzzer_options);
}

if (!caller) {
    exit main();
}
