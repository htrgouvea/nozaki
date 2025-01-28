package Engine::Orchestrator {
    use strict;
    use threads;
    use warnings;
    use Fcntl qw(O_RDONLY);
    use Engine::FuzzerThread;

    my $wordlist_queue;
    my @targets_queue :shared;

    sub fill_queue {
        my ($list, $number) = @_;

        for (1 .. $number) {
            return unless (@{$list} > 0);

            if (eof($list->[0])) {
                close shift @{$list};

                (@{$list} > 0) || $wordlist_queue->end();

                next;
            }

            my $filehandle = $list->[0];

            chomp(my $line = <$filehandle>);

            $wordlist_queue->enqueue($line);
        }
        
        return;
    }

    sub add_target {
        my (@targets) = @_;

        for my $target (@targets) {
            $target .= "/" unless $target =~ /\/$/;

            lock(@targets_queue);

            push @targets_queue, $target;
        }
        
        return;
    }

    sub run_fuzzer {
        my ($self, %options) = @_;
        my $target = undef;

        while (@targets_queue) {
            LOCKED: {
                lock(@targets_queue);
                $target = shift @targets_queue;
            }

            $self->threaded_fuzz($target, %options);
        }
        
        return 0;
    }

    sub threaded_fuzz {
        my ($self, $target, %options) = @_;

        my @current = map {
            my $filehandle;
            sysopen($filehandle, $_, O_RDONLY) || die "$0: Can't open $_: $!";

            $filehandle;
        } glob($options{wordlist});

        $wordlist_queue = Thread::Queue->new();

        my $CONCURRENT_TASKS = 10;

        fill_queue(\@current, $CONCURRENT_TASKS * $options{tasks});

        for (1 .. $options{tasks}) {
            Engine::FuzzerThread->new(
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
                $options{proxy},
                \&add_target
            );
        }

        while (threads->list(threads::running) > 0) {
            fill_queue(\@current, $options{tasks});
        }

        map { $_->join() } threads->list(threads::all);

        close $_ for @current;

        return 0;
    }
}

1;