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
        my ($self, %options) = @_;

        my @current = map {
            open(my $fh, "<$_") || die "$0: Can't open $_: $!";
            $fh
        } glob($options{wordlist});
        
        $wordlist_queue = Thread::Queue -> new();

        fill_queue(\@current, 10 * $options{tasks});

        for (1 .. $options{tasks}) {
            Engine::FuzzerThread -> new (
                $wordlist_queue, 
                $options{target},
                $options{method},
                $options{agent},
                $options{headers},
                $options{accept},
                $options{timeout},
                $options{return},
                $options{payload},
                $options{json},
                $options{delay},
                $options{exclude},
                $options{skipssl},
                $options{length},
                # $options{plugin}
            );
        }

        while (threads -> list(threads::running) > 0) {
            fill_queue(\@current, $options{tasks});
        }

        map { $_ -> join() } threads -> list(threads::all);

        return 0;
    }
}

1;