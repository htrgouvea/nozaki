use strict;
use warnings;
use threads;
use threads::shared;
use Test::More;
use Test::MockModule;
use Thread::Queue;

use lib '../lib/';
use Engine::FuzzerThread;

my $report_sent :shared = 0;

my $mock_ua = Test::MockModule->new('Mojo::UserAgent');
$mock_ua->redefine(
    new => sub {
        my $ua = bless {}, 'Mojo::UserAgent';

        $mock_ua->redefine(
            post => sub {
                $report_sent++;
                return bless { error => undef }, 'Mojo::Message';
            },
            proxy => sub {
                return bless {
                    http => sub { return shift },
                    https => sub { return shift },
                }, 'Mojo::UserAgent::Proxy';
            },
            request_timeout => sub { return shift },
        );

        return $ua;
    }
);

my $mock_fuzzer = Test::MockModule->new('Engine::Fuzzer');
$mock_fuzzer->redefine(
    new => sub {
        return bless {}, 'Engine::Fuzzer';
    },
    request => sub {
        return {
            Method   => 'GET',
            URL      => 'http://target/ping',
            Code     => 200,
            Response => 'OK',
            Content  => 'ping',
            Length   => 4,
        };
    }
);

my $queue = Thread::Queue->new('/ping');

sub wait_for_report_sent {
    my ($timeout) = @_;
    $timeout ||= 5;
    my $elapsed = 0;
    while ($elapsed < $timeout * 10) {
        return 1 if $report_sent > 0;
        select(undef, undef, undef, 0.1);
        $elapsed++;
    }
    return 0;
}

$report_sent = 0;
Engine::FuzzerThread->new(
    $queue,
    'http://target',
    'GET',
    'Agent',
    {}, '*/*', 5, '200', undef, 0, 0, undef, 0, undef, undef,
    undef, 'http://proxy', 'json'
);
ok(wait_for_report_sent(), 'Report was sent when return code matched');

$mock_fuzzer->redefine(
    request => sub {
        return {
            Code     => 404,
            Length   => 5,
            Content  => 'ping',
            Method   => 'GET',
            URL      => 'http://target/404',
            Response => 'Not Found'
        };
    }
);
$queue = Thread::Queue->new('/404');
$report_sent = 0;
Engine::FuzzerThread->new(
    $queue,
    'http://target',
    'GET',
    'Agent',
    {}, '*/*', 5, '200', undef, 0, 0, undef, 0, undef, undef,
    undef, 'http://proxy', 'json'
);
ok(!wait_for_report_sent(2), 'Report was not sent when return code mismatched');

done_testing();
