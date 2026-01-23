package Engine::Orchestrator  {
    use strict;
    use threads;
    use warnings;
    use Carp qw(croak);
    use Engine::FuzzerThread;

    our $VERSION = "0.3.1";

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

        my @current;
        my @wordlists = split /,/x, $options{wordlist};

        for my $wordlist (@wordlists) {
            open(my $filehandle, "<", $wordlist)
                || croak "$0: Can't open $wordlist: $!";

            my @lines = <$filehandle>;
            close $filehandle;

            chomp @lines;
            push @current, @lines;
        }

        $wordlist_queue = Thread::Queue -> new();

        my $concurrent_tasks = 10;

        fill_queue(\@current, $concurrent_tasks * $options{tasks});

        for (1 .. $options{tasks}) {
            Engine::FuzzerThread -> new(
                queue               => $wordlist_queue,
                target              => $target,
                methods             => $options{method},
                agent               => $options{agent},
                headers             => $options{headers},
                accept              => $options{accept},
                timeout             => $options{timeout},
                return              => $options{return},
                payload             => $options{payload},
                json                => $options{json},
                delay               => $options{delay},
                exclude             => $options{exclude},
                skipssl             => $options{skipssl},
                length_filter       => $options{length},
                content             => $options{content},
                content_type_filter => $options{content_type},
                proxy               => $options{proxy}
            );
        }

        while (threads -> list(threads::running) > 0) {
            fill_queue(\@current, $options{tasks});
        }

        for my $thread (threads -> list(threads::all)) {
            $thread -> join();
        }

        return 0;
    }
}

1;
