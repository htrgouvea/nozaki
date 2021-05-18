package Engine::Orchestrator  {
    use strict;
    use warnings;
    use Engine::FuzzerThread;

    my $wordlist_queue;

    sub fill_queue {
        my ($list, $n) = @_;
        
        for (1 .. $n) {
            return unless (@{$list} > 0);
            
            if (eof($list -> [0])) {
                close shift @{$list};
                (@{$list} > 0) || $wordlist_queue -> end();
                next
            }

            my $fh = $list -> [0];
            chomp(my $line = <$fh>);
            $wordlist_queue -> enqueue($line);
        }
    }

    sub run_fuzzer {
        my ($self, $target, $args) = @_;
        my ($return, $payload, %headers, $accept, $json, $exclude, $skipssl);
        my $delay    = 0;
        my $timeout  = 10;
        my $agent    = "Nozaki / 0.2.4";
        my $wordlist = "wordlists/default.txt";
        my $methods  = "GET,POST,PUT,DELETE,HEAD,OPTIONS,TRACE,PATCH,PUSH";
        my $tasks    = 10;

        Getopt::Long::GetOptionsFromArray (
            $args,
            "accept=s"   => \$accept,
            "wordlist=s" => \$wordlist,
            "method=s"   => \$methods,
            "delay=i"    => \$delay,
            "timeout=i"  => \$timeout,
            "agent=s"    => \$agent,
            "return=s"   => \$return,
            "payload=s"  => \$payload,
            "json"       => \$json,
            "header=s%"  => \%headers,
            "tasks=i"    => \$tasks,
            "exclude=s"  => \$exclude,
            "skip-ssl"   => \$skipssl,
        );

        my @current = map {
            open(my $fh, "<$_") || die "$0: Can't open $_: $!";
            $fh
        } glob($wordlist);
        
        $wordlist_queue = Thread::Queue -> new();

        fill_queue(\@current, 10 * $tasks);

        for (1 .. $tasks) {
            Engine::FuzzerThread -> new (
                $wordlist_queue, $target, $methods, $agent, \%headers, $accept, $timeout, $return, $payload, $json, $delay, $exclude, $skipssl
            );
        }

        while (threads -> list(threads::running) > 0) {
            fill_queue(\@current, $tasks);
        }

        map { $_ -> join() } threads -> list(threads::all);

        return 1;
    }
}

1;