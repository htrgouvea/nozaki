package Engine::FuzzerThread {
    use JSON;
    use strict;
    use threads;
    use warnings;
    use Engine::Fuzzer;

    our $VERSION = '0.0.1';

    sub new {
        my (
            $self, $queue, $target, $methods, $agent, $headers, $accept, $timeout, $return,
            $payload, $json, $delay, $exclude, $skipssl, $length, $content, $proxy, $add_target_ref, $targets_cycle, $counter_ref
        ) = @_;

        my @verbs         = split (/,/xsm, $methods);
        my @valid_codes   = split /,/x, $return || '';
        my @invalid_codes = split /,/x, $exclude || '';

        my $fuzzer = Engine::Fuzzer -> new($timeout, $headers, $skipssl, $proxy);
        my $format = JSON -> new() -> allow_nonref();

        my $cmp;

        if ($length) {
            ($cmp, $length) = $length =~ /([>=<]{0,2})(\d+)/xsm;

            $cmp = sub { $_[0] >= $length } if ($cmp eq '>=');
            $cmp = sub { $_[0] <= $length } if ($cmp eq '<=');
            $cmp = sub { $_[0] != $length } if ($cmp eq '<>');
            $cmp = sub { $_[0]  > $length } if ($cmp eq  '>');
            $cmp = sub { $_[0]  < $length } if ($cmp eq  '<');
            $cmp = sub { $_[0] == $length } if (!$cmp or $cmp eq '=');
        }

        my $use_cycle = $targets_cycle && @{$targets_cycle} > 0;
        my $target_count = $use_cycle ? scalar(@{$targets_cycle}) : 0;

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
                    my $target_index = $current_index % $target_count;
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

                    if (grep(/^$status$/xsm, @invalid_codes) || ($return && !grep(/^$status$/xsm, @valid_codes))) {
                        next;
                    }

                    if ($length && !($cmp -> ($result -> {Length}))) {
                        next;
                    }

                    my $message = $json ? $format -> encode($result) : sprintf(
                        "Code: %d | URL: %s | Method: %s | Response: %s | Length: %s",
                        $status, $result -> {URL}, $result -> {Method}, $result -> {Response} || '?', $result -> {Length}
                    );

                    if (!$content || $result -> {Content} =~ m/$content/xsm) {
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