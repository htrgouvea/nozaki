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

    sub _build_comparator {
        my ($length_filter) = @_;

        my ($op, $val) = $length_filter =~ /([>=<]{0,2})(\d+)/xsm;

        my $cmp;
        $cmp = sub { $_[0] >= $val } if $op eq '>=';
        $cmp = sub { $_[0] <= $val } if $op eq '<=';
        $cmp = sub { $_[0] != $val } if $op eq '<>';
        $cmp = sub { $_[0]  > $val } if $op eq  '>';
        $cmp = sub { $_[0]  < $val } if $op eq  '<';
        $cmp = sub { $_[0] == $val } if (!$cmp || $op eq '=');

        return ($cmp, $val);
    }

    sub _send_report {
        my (%args) = @_;

        my $report_ua     = $args{report_ua};
        my $report_to     = $args{report_to};
        my $report_format = $args{report_format};
        my $verb          = $args{verb};
        my $endpoint      = $args{endpoint};
        my $headers       = $args{headers};
        my $agent         = $args{agent};
        my $accept        = $args{accept};
        my $payload       = $args{payload};
        my $result        = $args{result};

        try {
            if ($report_format && $report_format eq 'json') {
                my $report_data = {
                    request => {
                        method  => $verb,
                        url     => $endpoint,
                        headers => { %{$headers}, 'User-Agent' => $agent },
                        payload => $payload || q()
                    },
                    response => $result
                };
                my $tx = $report_ua->post($report_to => json => $report_data);
                if ($tx->error) {
                    carp 'Failed to send JSON report to ' . $report_to . q(: ) . $tx->error->{message};
                }
                return;
            }

            my $tx = $report_ua->build_tx(
                $verb => $endpoint => {
                    'User-Agent' => $agent,
                    %{$headers},
                    'Accept'     => $accept
                } => $payload || q()
            );
            $tx = $report_ua->start($tx);
        }
        catch {
            carp "Failed to send report to $report_to: $_";
        };

        return;
    }

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

        my @verbs         = split /,/xsm, $methods;
        my @valid_codes   = split /,/x,   $return  || q();
        my @invalid_codes = split /,/x,   $exclude || q();

        my $fuzzer    = Engine::Fuzzer -> new($timeout, $headers, $skipssl, $proxy);
        my $format    = JSON -> new() -> allow_nonref();
        my $report_ua = $report_to ? Mojo::UserAgent->new()->request_timeout($timeout) : undef;

        if ($report_to && $report_ua) {
            $report_ua->proxy->http($report_to)->https($report_to);
        }

        my ($cmp, $length_val);
        if ($length) {
            ($cmp, $length_val) = _build_comparator($length);
        }

        my $use_cycle    = $targets_cycle && @{$targets_cycle} > 0;
        my $target_count = $use_cycle ? scalar @{$targets_cycle} : 0;

        async {
            while (defined(my $resource = $queue -> dequeue())) {
                my $endpoint;

                if ($use_cycle) {
                    my $current_index;
                    {
                        lock(${$counter_ref});
                        $current_index = ${$counter_ref};
                        ${$counter_ref}++;
                    }
                    my $target_index  = $current_index % $target_count;
                    my $cycled_target = $targets_cycle -> [$target_index];
                    $endpoint = $cycled_target . $resource;
                } else {
                    $endpoint = $target . $resource;
                }

                my $found = 0;

                for my $verb (@verbs) {
                    my $result = $fuzzer -> request($verb, $agent, $endpoint, $payload, $accept);

                    unless ($result) {
                        next;
                    }

                    my $status = $result -> {Code};

                    if (   grep { /^$status$/xsm } @invalid_codes
                        || ($return && !grep { /^$status$/xsm } @valid_codes)) {
                        next;
                    }

                    if ($length_val && !($cmp -> ($result -> {Length}))) {
                        next;
                    }

                    if ($content && $result -> {Content} !~ m/$content/x) { ## no critic (RegularExpressions::RequireExtendedFormatting)
                        next;
                    }

                    my $message = $json ? $format -> encode($result) : sprintf(
                        'Code: %d | URL: %s | Method: %s | Response: %s | Length: %s',
                        $status, $result -> {URL}, $result -> {Method}, $result -> {Response} || '?', $result -> {Length}
                    );

                    print $message, "\n";

                    if ($report_to && $report_ua) {
                        _send_report(
                            report_ua     => $report_ua,
                            report_to     => $report_to,
                            report_format => $report_format,
                            verb          => $verb,
                            endpoint      => $endpoint,
                            headers       => $headers,
                            agent         => $agent,
                            accept        => $accept,
                            payload       => $payload,
                            result        => $result,
                        );
                    }

                    sleep($delay);

                    $found = 1;
                }
            }
        };

        return 1;
    }
}

1;
