package Engine::FuzzerThread {
    use JSON;
    use strict;
    use threads;
    use warnings;
    use Engine::Fuzzer;
    use Mojo::UserAgent;
    use Try::Tiny;

    sub new {
        my (
            $self, $queue, $target, $methods, $agent, $headers, $accept, $timeout, $return,
            $payload, $json, $delay, $exclude, $skipssl, $length, $content, $proxy, $report_to, $report_format
        ) = @_;

        my @verbs         = split (/,/, $methods);
        my @valid_codes   = split /,/, $return || "";
        my @invalid_codes = split /,/, $exclude || "";

        my $fuzzer = Engine::Fuzzer -> new($timeout, $headers, $skipssl, $proxy);
        my $format = JSON -> new() -> allow_nonref();
        my $report_ua = $report_to ? Mojo::UserAgent->new()->request_timeout($timeout) : undef;

        if ($report_to && $report_ua) {
            $report_ua->proxy->http($report_to)->https($report_to);
        }

        my $cmp;

        if ($length) {
            ($cmp, $length) = $length =~ /([>=<]{0,2})(\d+)/;

            $cmp = sub { $_[0] >= $length } if ($cmp eq ">=");
            $cmp = sub { $_[0] <= $length } if ($cmp eq "<=");
            $cmp = sub { $_[0] != $length } if ($cmp eq "<>");
            $cmp = sub { $_[0]  > $length } if ($cmp eq  ">");
            $cmp = sub { $_[0]  < $length } if ($cmp eq  "<");
            $cmp = sub { $_[0] == $length } if (!$cmp or $cmp eq "=");
        }

        async {
            while (defined(my $resource = $queue -> dequeue())) {
                my $endpoint = $target . $resource;
                my $found = 0;

                for my $verb (@verbs) {
                    my $result = $fuzzer -> request($verb, $agent, $endpoint, $payload, $accept);

                    unless ($result) {
                        next;
                    }

                    my $status = $result -> {Code};

                    if (grep(/^$status$/, @invalid_codes) || ($return && !grep(/^$status$/, @valid_codes))) {
                        next;
                    }
                    
                    if ($length && !($cmp -> ($result -> {Length}))) {
                        next;
                    }

                    if ($content && $result -> {Content} !~ m/$content/) {
                        next;
                    }

                    my $message = $json ? $format -> encode($result) : sprintf(
                        "Code: %d | URL: %s | Method: %s | Response: %s | Length: %s",
                        $status, $result -> {URL}, $result -> {Method}, $result -> {Response} || "?", $result -> {Length}
                    );

                    print $message, "\n";

                    if ($report_to && $report_ua) {
                        try {
                            if ($report_format && $report_format eq 'json') {
                                my $report_data = {
                                    request => {
                                        method  => $verb,
                                        url     => $endpoint,
                                        headers => { %{$headers}, "User-Agent" => $agent },
                                        payload => $payload || ""
                                    },
                                    response => $result
                                };
                                my $tx = $report_ua->post($report_to => json => $report_data);
                                if ($tx->error) {
                                    warn "Failed to send JSON report to $report_to: " . $tx->error->{message} . "\n";
                                }
                                return;
                            }
                            
                            my $tx = $report_ua->build_tx(
                                $verb => $endpoint => {
                                    "User-Agent" => $agent,
                                    %{$headers},
                                    "Accept" => $accept
                                } => $payload || ""
                            );
                            $tx = $report_ua->start($tx);
                        } 
                        
                        catch {
                            warn "Failed to send report to $report_to: $_";
                        };
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