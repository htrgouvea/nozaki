#!/usr/bin/env perl

use JSON;
use 5.018;
use strict;
use warnings;
use lib "./lib/";
use Engine::Fuzzer;
use Functions::Utils;
use Functions::Helper;
use Parallel::ForkManager;
use Getopt::Long qw(:config no_ignore_case);

sub fuzzer_thread
{
    my ($endpoint, $methods,$agent, $headers, $accept,
        $timeout, $return, $payload, $json, $delay) = @_;
    
    my $fuzzer = Engine::Fuzzer->new(
            useragent => $agent,
            timeout => $timeout,
            headers => $headers,
    );
    
    my @verbs = split /,/, $methods;
    for my $verb (@verbs)
    {
        my $result = $fuzzer->fuzz($endpoint, $verb, $payload, $accept);

        next if $return && $result->{Code} != $return;
        
        my $printable = $json ? encode_json($result) : sprintf(
            "[%d] URL: %s | Method: %s | Response: %s | Length: %s",
            $result->{Code}, $result->{URL}, $result->{Method},
            $result->{Response}, $result->{Length}
        );
        print $printable . "\n";
        sleep($delay);
    }
}

sub main
{
    my ($target, $return, $payload);
    my %headers;
    my $agent    = "Nozaki CLI / 0.1.1";
    my $delay    = 0;
    my $timeout  = 10;
    my $wordlist = "wordlists/default.txt";
    my $methods  = "GET,POST,PUT,DELETE,HEAD,OPTIONS,CONNECT,TRACE,PATCH,SUBSCRIBE,MOVE,REPORT,UNLOCK,%s%s%s%s"
                    . "PURGE,POLL,NOTIFY,SEARCH,1337,CATS,*,DATA,HEADERS,PRIORITY,RST_STREAM,SETTINGS,PUSH_PROMISE"
                    . "PING,GOAWAY,WINDOW_UPDATE,CONTINUATION";
    #use only 10 threads by default
    my $tasks    = 10; 
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
    my @wordlist;
    while (<$file>)
    {
        chomp;
        push @wordlist, $_;
    }
    close ($file);

    my $threadmgr = Parallel::ForkManager->new($tasks);
    $threadmgr->set_waitpid_blocking_sleep(0);
    THREADS:
    for (@wordlist)
    {
        my $endpoint = url_join($target, $_);
        $threadmgr->start() and next THREADS;
        
        fuzzer_thread($endpoint, $methods, $agent, \%headers, $accept,
            $timeout, $return, $payload, $json, $delay);
        
        $threadmgr->finish();
    }
    $threadmgr->wait_all_children;

    print "Finished.\n";
    
    return 0;
}

exit main();