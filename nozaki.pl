#!/usr/bin/env perl

use JSON;
use 5.018;
use strict;
use threads;
use warnings;
use Thread::Queue;
use Find::Lib "./lib";
use Functions::Helper;
use Functions::Parser;
use Engine::Fuzzer;
use Time::HiRes qw( gettimeofday tv_interval );
use Getopt::Long qw(:config no_ignore_case pass_through);

my $wordlist_queue = Thread::Queue->new();

sub fuzzer_thread {
    my (
        $target, $methods, $agent, $headers, $accept, $timeout, $return, $payload, $json, $delay, $exclude, $skipssl
    ) = @_;
        
    my @verbs = split (/,/, $methods);
    my @valid_codes = split /,/, $return || "";
    my @invalid_codes = split /,/, $exclude || "";
    my $fuzzer = Engine::Fuzzer->new($timeout, $headers, $skipssl);
    while (defined(my $resource = $wordlist_queue->dequeue()))
    {
        my $endpoint = $target . $resource;
        for my $verb (@verbs) {
            my $result = $fuzzer->request($verb, $agent, $endpoint, $payload, $accept);
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
    
}

sub fill_queue {
    my ($list, $n) = @_;
    for (1 .. $n)
    {
        return unless (@{$list} > 0);
        if (eof($list->[0])) {
            close shift @{$list};
            (@{$list} > 0) || $wordlist_queue->end();
            next
        }
        my $fh = $list->[0];
        chomp(my $line = <$fh>);
        $wordlist_queue->enqueue($line);
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

    my @current = map {
        open(my $fh, "<$_") || die "$0: Can't open $_: $!";
        $fh
    } glob($wordlist);
    
    fill_queue(\@current, 10 * $tasks);
    
    my $start_at = [gettimeofday];

    async {
        fuzzer_thread($target, $methods, $agent, \%headers, $accept, $timeout, $return, $payload, $json, $delay, $exclude, $skipssl);
    } for 1 .. $tasks;

    while (threads->list(threads::running) > 0) {
        fill_queue(\@current, $tasks);
    }
    map { $_ -> join() } threads->list(threads::all);

    my $elapsed = tv_interval($start_at);

    print "Done in $elapsed seconds.\n";

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