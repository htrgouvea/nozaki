#!/usr/bin/env perl

use JSON;
use 5.018;
use strict;
use threads;
use warnings;
use Getopt::Long;
use lib "./lib/";
use Thread::Queue;
use Engine::Fuzzer;
use threads::shared;
use Functions::Utils;
use Functions::Helper;

my $endpoint_queue = Thread::Queue->new();

sub fuzzer_thread
{
    my ($target, $methods,
        $agent, $headers,
        $accept, $timeout,
        $return, $payload,
        $json, $delay) = @_;
    
    my $fuzzer = Engine::Fuzzer->new(
        useragent => $agent,
        timeout => $timeout,
        headers => { %$headers },
    );
    
    my @verbs = split /,/, $methods;

    while (defined(my $res = $endpoint_queue->dequeue()))
    {
        my $endpoint = url_join($target, $res);
        for my $verb (@verbs)
        {
            my $result = $fuzzer->fuzz($endpoint, $verb, $payload, $accept);

            next if $return && $result->{Code} != $return;
            
            my $printable;
            
            if ($json)
            {
                $printable = encode_json($result);
            }
            else
            {
                $printable = sprintf(
                    "[%d] URL: %s | Method: %s | Response: %s | Length: %s",
                    $result->{Code}, $result->{URL}, $result->{Method},
                    $result->{Response}, $result->{Length}
                );
            }
            print $printable . "\n";
            sleep($delay);
        }
    }
}

sub main
{
    my ($target, $return, $payload);
    my %headers;
    my $agent    = "Nozaki CLI / 0.1.1";
    my $delay    = 0.3;
    my $timeout  = 10;
    my $wordlist = "wordlists/default.txt";
    my $methods  = "GET,POST,PUT,DELETE,HEAD,OPTIONS,CONNECT,TRACE,PATCH,SUBSCRIBE,MOVE,REPORT,UNLOCK,%s%s%s%s"
                    . "PURGE,POLL,NOTIFY,SEARCH,1337,CATS,*,DATA,HEADERS,PRIORITY,RST_STREAM,SETTINGS,PUSH_PROMISE"
                    . "PING,GOAWAY,WINDOW_UPDATE,CONTINUATION";
    #use only 5 threads by default
    my $tasks    = 5; 
    my $json     = 0;
    my $accept;

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
    ) or die ( return Functions::Helper -> new() );
    return Functions::Helper->new() unless $target && $wordlist;
    
    open (my $file, "<", $wordlist) || die "$0: Can't open $wordlist";

    while (<$file>)
    {
        chomp;
        $endpoint_queue->enqueue($_);
    }

    $endpoint_queue->end();
    close ($file);

    #threads
    async {
        foreach (1 .. $tasks)
        {
            threads->create("fuzzer_thread", $target, $methods, $agent,
                \%headers, $accept, $timeout, $return, $payload, $json, $delay
            );
        }
    };

    while (threads->list(threads::running) > 0) {};
    map { $_->join() } threads->list(threads::all);
    print "Done.\n";
    return 0;    
}

exit main();