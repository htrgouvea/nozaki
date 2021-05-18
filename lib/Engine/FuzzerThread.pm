package Engine::FuzzerThread {
    use JSON;
    use strict;
    use threads;
    use warnings;
    use Engine::Fuzzer;

    sub new {
        my ($self, $queue, $target, $methods, $agent, $headers, $accept, $timeout, $return, $payload, $json, $delay, $exclude, $skipssl) = @_;
        my @verbs = split (/,/, $methods);
        my @valid_codes = split /,/, $return || "";
        my @invalid_codes = split /,/, $exclude || "";
        my $fuzzer = Engine::Fuzzer -> new($timeout, $headers, $skipssl);
        my $format = JSON -> new -> allow_nonref -> pretty;
        
        async {
            while (defined(my $resource = $queue -> dequeue())) {
                my $endpoint = $target . $resource;
                
                for my $verb (@verbs) {
                    my $result = $fuzzer -> request($verb, $agent, $endpoint, $payload, $accept);
                    my $status = $result -> {Code};
                    next if grep(/^$status$/, @invalid_codes) || ($return && !grep(/^$status$/, @valid_codes));
                    my $printable = $json ? $format->encode($result) : sprintf(
                        "Code: %d | URL: %s | Method: %s | Response: %s | Length: %s",
                        $status, $result -> {URL}, $result -> {Method},
                        $result -> {Response} || "?", $result -> {Length}
                    );

                    print $printable, "\n";
                    sleep($delay);
                }
            }
        };

        return 1;
    }
}

1;