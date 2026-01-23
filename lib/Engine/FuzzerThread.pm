package Engine::FuzzerThread {
    use strict;
    use threads;
    use warnings;
    use Engine::Fuzzer;
    use Engine::FuzzerThread::ContentTypeFilters;
    use Engine::FuzzerThread::LengthComparator;
    use Engine::FuzzerThread::MessageBuilder;
    use Engine::FuzzerThread::StatusFilters;
    use Functions::ContentTypeFilter;

    our $VERSION = '0.3.1';

    sub new {
        my ($self, %options) = @_;

        my @verbs = split /,/xms, $options{methods};

        my $fuzzer = Engine::Fuzzer -> new(
            timeout => $options{timeout},
            headers => $options{headers},
            skipssl => $options{skipssl},
            proxy   => $options{proxy}
        );
        my $status_filters = Engine::FuzzerThread::StatusFilters -> new(
            %options
        );
        my $length_comparator_config
            = Engine::FuzzerThread::LengthComparator -> new(%options);
        my $content_type_filters_config
            = Engine::FuzzerThread::ContentTypeFilters -> new(%options);
        my $message_builder_config
            = Engine::FuzzerThread::MessageBuilder -> new(%options);
        my $valid_code_lookup
            = $status_filters -> {valid_code_lookup};
        my $invalid_code_lookup
            = $status_filters -> {invalid_code_lookup};
        my $has_valid_codes = $status_filters -> {has_valid_codes};
        my $length_comparator
            = $length_comparator_config -> {comparator};
        my $content_type_filters
            = $content_type_filters_config -> {content_type_filters};
        my $message_builder = $message_builder_config -> {builder};

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

                    if (!$result) {
                        next;
                    }

                    my $status = $result -> {Code};

                    my $is_invalid = 0;

                    if ($invalid_code_lookup -> {$status}) {
                        $is_invalid = 1;
                    }

                    if ($has_valid_codes && !$valid_code_lookup -> {$status}) {
                        $is_invalid = 1;
                    }

                    if ($is_invalid) {
                        next;
                    }

                    if ($options{length_filter}) {
                        if (!($length_comparator -> ($result -> {Length}))) {
                            next;
                        }
                    }

                    if ($options{content_type_filter}) {
                        my $matches = Functions::ContentTypeFilter::content_type_matches(
                            $result -> {ContentType},
                            $content_type_filters
                        );

                        if (!$matches) {
                            next;
                        }
                    }

                    if (!$options{content}
                        || $result -> {Content} =~ m/$options{content}/xms) {
                        my $message = $message_builder -> ($result);

                        print $message, "\n";
                    }

                    sleep $options{delay};
                    $was_found = 1;
                }
            }
        };

        return 1;
    }

}

1;
