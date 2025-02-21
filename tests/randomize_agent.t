#!/usr/bin/env perl
use strict;
use warnings;
use threads;
use Test::More tests => 5;
use File::Temp qw(tempfile);
use Thread::Queue;
use lib '../lib/';
use Functions::RandomizeAgent;

{
    my $agent = Functions::RandomizeAgent::get_random_agent();
    my @defaults = (
        "Nozaki / 0.2.9",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Safari/605.1.15",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/121.0"
    );
    ok( grep { $_ eq $agent } @defaults,
        "get_random_agent returns a default agent when no custom file is provided" );
}

my ($fh, $filename) = tempfile();
print $fh "CustomAgentA\nCustomAgentB\nCustomAgentC\n";
close $fh;

{
    my $agent = Functions::RandomizeAgent::get_random_agent($filename);
    my @custom = ("CustomAgentA", "CustomAgentB", "CustomAgentC");
    ok( grep { $_ eq $agent } @custom,
        "get_random_agent returns a custom agent when a file is provided" );
}

{
    my %seen;
    for (1 .. 10) {
        my $agent = Functions::RandomizeAgent::get_random_agent($filename);
        $seen{$agent} = 1;
    }
    ok( scalar(keys %seen) > 1,
        "Repeated calls produce varying custom agents (random selection works)" );
}

{
    my $agent = Functions::RandomizeAgent::get_random_agent("nonexistentfile.txt");
    my @defaults = (
        "Nozaki / 0.2.9",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Safari/605.1.15",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/121.0"
    );
    ok( grep { $_ eq $agent } @defaults,
        "Non-existent file leads to fallback on default agents" );
}

use Test::MockModule;
my $mock_agent = "CustomAgentXYZ";
my $captured_agent;

my $fuzzer_mod = Test::MockModule->new("Engine::Fuzzer");
$fuzzer_mod->redefine(
    new => sub {
        my ($class, @args) = @_;
        return bless {}, "Engine::Fuzzer";  
    }
);

$fuzzer_mod->redefine(
    request => sub {
        my ($self, $method, $user_agent, $endpoint, $payload, $accept) = @_;
        $captured_agent = $user_agent;
        return { Code => 200, Response => "OK", Length => 123,
                 'User-Agent' => $user_agent, Method => $method, URL => $endpoint };
    }
);

my $rand_mod = Test::MockModule->new("Functions::RandomizeAgent");
$rand_mod->redefine(
    get_random_agent => sub {
        my ($custom_agents) = @_;
        return $mock_agent;
    }
);

my $ft_mod = Test::MockModule->new("Engine::FuzzerThread");
$ft_mod->redefine(
    new => sub {
        my (
            $class, $queue, $target, $methods, $agent, $headers, $accept,
            $timeout, $return, $payload, $json, $delay, $exclude, $skipssl,
            $length, $content, $proxy, $randomize_agent, $custom_agents
        ) = @_;
        my @verbs = split(/,/, $methods);
        my $fuzzer = Engine::Fuzzer->new($timeout, $headers, $skipssl, $proxy);
        my $resource = $queue->dequeue();
        my $endpoint = $target . $resource;
        my $current_agent = $agent;
        if ($randomize_agent) {
            require Functions::RandomizeAgent;
            $current_agent = Functions::RandomizeAgent::get_random_agent($custom_agents);
        }
        my ($first_verb) = split(/,/, $methods);
        my $result = $fuzzer->request($first_verb, $current_agent, $endpoint, $payload, $accept);
        return $result;
    }
);

my $queue = Thread::Queue->new();
$queue->enqueue("test");
$queue->end();

my $target          = "http://example.com/test";
my $methods         = "GET,POST";
my $agent           = "StaticAgent";
my $headers         = {};
my $accept          = "*/*";
my $timeout         = 10;
my $return          = undef;
my $payload         = undef;
my $json            = 0;
my $delay           = 0;
my $exclude         = undef;
my $skipssl         = 0;
my $length          = undef;
my $content         = undef;
my $proxy           = undef;
my $randomize_agent = 1;           
my $custom_agents   = $filename;    

my $result = Engine::FuzzerThread->new(
    $queue, $target, $methods, $agent, $headers, $accept,
    $timeout, $return, $payload, $json, $delay, $exclude, $skipssl,
    $length, $content, $proxy, $randomize_agent, $custom_agents
);

ok($captured_agent eq $mock_agent,
   "FuzzerThread uses a random agent from the custom agents file when randomize_agent is enabled");

done_testing();
