package Engine::FuzzerThread {
    use JSON;
    use strict;
    use threads;
    use warnings;
    use Carp qw(carp);
    use Engine::Fuzzer;
    use Mojo::UserAgent;
    use Try::Tiny;

    our $VERSION = '0.0.1';

    sub new {
        my ($self, %options) = @_;

        my $queue         = $options{queue};
        my $target        = $options{target};
        my $methods       = $options{methods};
        my $agent         = $options{agent};
        my $headers       = $options{headers};
        my $accept        = $options{accept};
        my $timeout       = $options{timeout};
        my $return        = $options{return};
        my $payload       = $options{payload};
        my $json          = $options{json};
        my $delay         = $options{delay};
        my $exclude       = $options{exclude};
        my $skipssl       = $options{skipssl};
        my $length        = $options{length};
        my $content       = $options{content};
        my $proxy         = $options{proxy};
        my $report_to     = $options{report_to};
        my $report_format = $options{report_format};
        my $targets_cycle = $options{targets_cycle};
        my $counter_ref   = $options{counter};

        my @verbs          = split /,/xsm, $methods;
        my %invalid_status = map { $_ => 1 } split /,/x, $exclude // q();
        my %valid_status   = map { $_ => 1 } split /,/x, $return  // q();

        my $fuzzer = Engine::Fuzzer->new($timeout, $headers, $skipssl, $proxy);
        my $format = JSON->new()->allow_nonref();

        my $send_report = sub { return };
        if ($report_to) {
            my $ua = Mojo::UserAgent->new()->request_timeout($timeout);
            $ua->proxy->http($report_to)->https($report_to);
            $send_report = sub {
                my ($verb, $endpoint, $result) = @_;
                try {
                    if ($report_format && $report_format eq 'json') {
                        my $data = {
                            request  => {
                                method  => $verb,
                                url     => $endpoint,
                                headers => { %{$headers}, 'User-Agent' => $agent },
                                payload => $payload // q(),
                            },
                            response => $result,
                        };
                        my $tx = $ua->post($report_to => json => $data);
                        if ($tx->error) {
                            carp 'Failed to send JSON report to ' . $report_to . q(: ) . $tx->error->{message};
                        }
                        return;
                    }
                    my $tx = $ua->build_tx(
                        $verb => $endpoint =>
                        { 'User-Agent' => $agent, %{$headers}, 'Accept' => $accept } =>
                        $payload // q()
                    );
                    $ua->start($tx);
                }
                catch { carp "Failed to send report to $report_to: $_" };
                return;
            };
        }

        my $check_length = sub { 1 };
        if ($length) {
            my ($op, $val) = $length =~ /([>=<]{0,2})(\d+)/xsm;
            my %op_map = (
                '>=' => sub { $_[0] >= $val },
                '<=' => sub { $_[0] <= $val },
                '<>' => sub { $_[0] != $val },
                '>'  => sub { $_[0]  > $val },
                '<'  => sub { $_[0]  < $val },
                '='  => sub { $_[0] == $val },
                q()  => sub { $_[0] == $val },
            );
            $op = q() unless exists $op_map{$op};
            $check_length = $op_map{$op};
        }

        my $check_content = sub { 1 };
        if ($content) {
            $check_content = sub { $_[0] =~ m/$content/xsm };
        }

        my $target_count = $targets_cycle ? scalar @{$targets_cycle} : 0;

        async {
            while (defined(my $resource = $queue->dequeue())) {
                my $endpoint;
                if ($target_count) {
                    my $idx;
                    { lock(${$counter_ref}); $idx = ${$counter_ref}++; }
                    $endpoint = $targets_cycle->[$idx % $target_count] . $resource;
                } else {
                    $endpoint = $target . $resource;
                }

                my $found = 0;

                for my $verb (@verbs) {
                    my $result = $fuzzer->request($verb, $agent, $endpoint, $payload, $accept);

                    unless ($result) { next; }

                    my $status = $result->{Code};
                    next if $invalid_status{$status};
                    next if $return && !$valid_status{$status};
                    next unless $check_length->($result->{Length});
                    next unless $check_content->($result->{Content});

                    my $message = $json
                        ? $format->encode($result)
                        : sprintf('Code: %d | URL: %s | Method: %s | Response: %s | Length: %s',
                            $status, $result->{URL}, $result->{Method},
                            $result->{Response} // q(?), $result->{Length});

                    print $message, "\n";
                    $send_report->($verb, $endpoint, $result);
                    sleep($delay);
                    $found = 1;
                }
            }
        };

        return 1;
    }
}

1;
