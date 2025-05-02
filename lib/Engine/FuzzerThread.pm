package Engine::FuzzerThread {
    use JSON;
    use strict;
    use threads;
    use warnings;
    use Engine::Fuzzer;

    sub new {
        my (
            $self, $queue, $target, $methods, $agent, $headers, $accept, $timeout, $return,
            $payload, $json, $delay, $exclude, $skipssl, $length, $content, $proxy
        ) = @_;

        my @verbs         = split (/,/x, $methods);
        my @valid_codes   = split /,/x, $return || "";
        my @invalid_codes = split /,/x, $exclude || "";

        my $fuzzer = Engine::Fuzzer -> new($timeout, $headers, $skipssl, $proxy);
        my $format = JSON -> new() -> allow_nonref();

        my $cmp;

        if ($length) {
            ($cmp, $length) = $length =~ /([>=<]{0,2})(\d+)/x;

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

                    if (grep(/^$status$/x, @invalid_codes) || ($return && !grep(/^$status$/x, @valid_codes))) {
                        next;
                    }
                    
                    if ($length && !($cmp -> ($result -> {Length}))) {
                        next;
                    }

                    my $message = $json ? $format -> encode($result) : sprintf(
                        "Code: %d | URL: %s | Method: %s | Response: %s | Length: %s",
                        $status, $result -> {URL}, $result -> {Method}, $result -> {Response} || "?", $result -> {Length}
                    );

                    if (!$content || $result -> {Content} =~ m/$content/x) {
                        print $message, "\n"; 
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