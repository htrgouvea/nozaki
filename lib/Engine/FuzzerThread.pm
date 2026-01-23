package Engine::FuzzerThread {
    use JSON;
    use strict;
    use threads;
    use warnings;
    use Engine::Fuzzer;
    use Functions::ContentTypeFilter;

    our $VERSION = "0.3.1";

    sub new {
        my ($self, %options) = @_;

        my @verbs         = split /,/xms, $options{methods};
        my @valid_codes   = split /,/xms, $options{return} || q{};
        my @invalid_codes = split /,/xms, $options{exclude} || q{};

        my %valid_code_lookup = ();
        my %invalid_code_lookup = ();

        for my $code (@valid_codes) {
            if (length $code) {
                $valid_code_lookup{$code} = 1;
            }
        }

        for my $code (@invalid_codes) {
            if (length $code) {
                $invalid_code_lookup{$code} = 1;
            }
        }

        my $fuzzer = Engine::Fuzzer -> new(
            timeout => $options{timeout},
            headers => $options{headers},
            skipssl => $options{skipssl},
            proxy   => $options{proxy}
        );
        my $json_encoder = JSON -> new() -> allow_nonref();

        my @content_type_filters = ();

        if ($options{content_type_filter}) {
            @content_type_filters = split /,/x, $options{content_type_filter};
        }

        my $length_comparator;

        if ($options{length_filter}) {
            my $comparator_symbol;

            ($comparator_symbol, $options{length_filter})
                = $options{length_filter} =~ /([>=<]{0,2})(\d+)/xms;

            if ($comparator_symbol eq ">=") {
                $length_comparator = sub { $_[0] >= $options{length_filter} };
            }

            if ($comparator_symbol eq "<=") {
                $length_comparator = sub { $_[0] <= $options{length_filter} };
            }

            if ($comparator_symbol eq "<>") {
                $length_comparator = sub { $_[0] != $options{length_filter} };
            }

            if ($comparator_symbol eq ">") {
                $length_comparator = sub { $_[0] > $options{length_filter} };
            }

            if ($comparator_symbol eq "<") {
                $length_comparator = sub { $_[0] < $options{length_filter} };
            }

            if (!$comparator_symbol || $comparator_symbol eq "=") {
                $length_comparator = sub { $_[0] == $options{length_filter} };
            }
        }

        async {
            while (defined(my $resource = $options{queue} -> dequeue())) {
                my $endpoint = $options{target} . $resource;
                my $was_found = 0;

                for my $verb (@verbs) {
                    my $result = $fuzzer -> request(
                        method   => $verb,
                        agent    => $options{agent},
                        endpoint => $endpoint,
                        payload  => $options{payload},
                        accept   => $options{accept}
                    );

                    unless ($result) {
                        next;
                    }

                    my $status = $result -> {Code};

                    my $is_invalid = 0;

                    if ($invalid_code_lookup{$status}) {
                        $is_invalid = 1;
                    }

                    if ($options{return} && !$valid_code_lookup{$status}) {
                        $is_invalid = 1;
                    }

                    if ($is_invalid) {
                        next;
                    }

                    if ($options{length_filter}
                        && !($length_comparator -> ($result -> {Length}))) {
                        next;
                    }

                    if ($options{content_type_filter}) {
                        my $matches = Functions::ContentTypeFilter::content_type_matches(
                            $result -> {ContentType},
                            \@content_type_filters
                        );

                        if (!$matches) {
                            next;
                        }
                    }

                    if (!$options{content}
                        || $result -> {Content} =~ m/$options{content}/xms) {
                        my $message = q{};

                        if ($options{json}) {
                            $message = $json_encoder -> encode($result);
                        }

                        if (!$options{json}) {
                            $message = sprintf(
                                "Code: %d | URL: %s | Method: %s | Response: %s | Length: %s",
                                $status,
                                $result -> {URL},
                                $result -> {Method},
                                $result -> {Response} || "?",
                                $result -> {Length}
                            );
                        }

                        print $message, "\n";
                    }

                    sleep($options{delay});
                    $was_found = 1;
                }
            }
        };

        return 1;
    }

}

1;
