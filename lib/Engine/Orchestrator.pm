package Engine::Orchestrator  {
    use strict;
    use threads;
    use warnings;
    use Engine::FuzzerThread;

    my $wordlist_queue;
    my @targets_queue :shared;

    sub fill_queue {
        my ($list, $number) = @_;

        for (1 .. $number) {
            if (@{$list} <= 0) {
                $wordlist_queue -> end();
                return 0;
            }

            my $line = shift @{$list};

            $wordlist_queue -> enqueue($line);
        }

        return 1;
    }

    sub add_target {
        my (@targets) = @_;

        for my $target (@targets) {
            if ($target !~ /\/$/x) {
                $target .= "/";
            }

            lock(@targets_queue);

            push @targets_queue, $target;
        }

        return 1;
    }

    sub run_fuzzer {
        my ($self, %options) = @_;
        my $target = undef;

        while (@targets_queue) {
            LOCKED: {
                lock(@targets_queue);
                $target = shift @targets_queue;
            }

            $self -> threaded_fuzz($target, %options);
        }

        return 0;
    }

    sub threaded_fuzz {
        my ($self, $target, %options) = @_;

        my @current = ();
        my @wordlists = glob($options{wordlist});

        for my $wordlist (@wordlists) {
            open(my $filehandle, "<", $wordlist) or die "$0: Can't open $wordlist: $!";

            my @lines = <$filehandle>;

            close $filehandle;

            chomp @lines;

            push @current, @lines;
        }

        $wordlist_queue = Thread::Queue -> new();

        my $concurrent_tasks = 10;

        fill_queue(\@current, $concurrent_tasks * $options{tasks});

        for (1 .. $options{tasks}) {
            Engine::FuzzerThread -> new (
                $wordlist_queue,
                $target,
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
                $options{content},
                $options{content_type},
                $options{proxy},
                \&add_target
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
