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
        my $agent    = "Nozaki / 0.2.5";
        my $wordlist = "wordlists/default.txt";
        my $methods  = "GET,POST,PUT,DELETE,HEAD,OPTIONS,TRACE,PATCH,PUSH";
        my $tasks    = 10;
        my $length;

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
            "l|length=s"   => \$length,
        );

        my @current = map {
            open(my $fh, "<$_") || die "$0: Can't open $_: $!";
            $fh
        } glob($wordlist);
        
        $wordlist_queue = Thread::Queue -> new();

        fill_queue(\@current, 10 * $tasks);

        for (1 .. $tasks) {
            Engine::FuzzerThread -> new (
                $wordlist_queue, $target, $methods, $agent, \%headers, $accept, $timeout,
                $return, $payload, $json, $delay, $exclude, $skipssl, $length
            );
        }

        while (threads -> list(threads::running) > 0) {
            fill_queue(\@current, $tasks);
        }

        map { $_ -> join() } threads -> list(threads::all);

        return 0;
    }
}

1;