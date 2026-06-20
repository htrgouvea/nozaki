package Engine::Orchestrator  {
    use strict;
    use threads;
    use warnings;
    use Carp qw(croak);
    use Engine::FuzzerThread;

    our $VERSION = '0.0.1';

    my $CONCURRENT_TASKS = 10;
    my $wordlist_queue;
    my @targets_queue    :shared;
    my @targets_for_cycle :shared;
    my $cycle_counter    :shared = 0;

    sub fill_queue {
        my ($lines, $number) = @_;

        for (1 .. $number) {
            if (@{$lines} == 0) {
                $wordlist_queue -> end();
                return;
            }

            $wordlist_queue -> enqueue(shift @{$lines});
        }

        return;
    }

    sub add_target {
        my (@targets) = @_;

        for my $target (@targets) {
            $target .= '/' if $target !~ /\/$/x;

            lock(@targets_queue);

            push @targets_queue, $target;
        }

        return 1;
    }

    sub run_fuzzer {
        my ($self, %options) = @_;
        my $target = undef;

        if ($options{domaincycle} && @targets_queue > 1) {
            lock(@targets_for_cycle);
            @targets_for_cycle = @targets_queue;

            lock(@targets_queue);
            @targets_queue = ($targets_for_cycle[0]);
        }

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

        my @lines;
        for my $filename (glob($options{wordlist})) {
            open(my $filehandle, '<', $filename)
                or croak "$0: Can't open $filename: $!";
            push @lines, <$filehandle>;
            close $filehandle;
        }
        chomp @lines;

        $wordlist_queue = Thread::Queue -> new();

        fill_queue(\@lines, $CONCURRENT_TASKS * $options{tasks});

        for (1 .. $options{tasks}) {
            Engine::FuzzerThread -> new(
                queue         => $wordlist_queue,
                target        => $target,
                methods       => $options{method},
                agent         => $options{agent},
                headers       => $options{headers},
                accept        => $options{accept},
                timeout       => $options{timeout},
                return        => $options{return},
                payload       => $options{payload},
                json          => $options{json},
                delay         => $options{delay},
                exclude       => $options{exclude},
                skipssl       => $options{skipssl},
                length        => $options{length},
                content       => $options{content},
                proxy         => $options{proxy},
                report_to     => $options{report_to},
                report_format => $options{report_format},
                targets_cycle => ($options{domaincycle} ? \@targets_for_cycle : undef),
                counter       => ($options{domaincycle} ? \$cycle_counter : undef),
            );
        }

        while (threads -> list(threads::running) > 0) {
            fill_queue(\@lines, $options{tasks});
        }

        for my $thread (threads -> list(threads::all)) {
            $thread -> join();
        }

        return 0;
    }
}

1;
