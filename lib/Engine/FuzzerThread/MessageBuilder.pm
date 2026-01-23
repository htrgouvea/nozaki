package Engine::FuzzerThread::MessageBuilder {
    use JSON;
    use strict;
    use warnings;

    sub new {
        my ($class, %options) = @_;
        my $builder;

        if ($options{json}) {
            my $json_encoder = JSON -> new() -> allow_nonref();
            $builder = sub {
                my ($result) = @_;
                return $json_encoder -> encode($result);
            };
        }

        if (!$options{json}) {
            $builder = sub {
                my ($result) = @_;
                return sprintf(
                    'Code: %d | URL: %s | Method: %s | Response: %s | Length: %s',
                    $result -> {Code},
                    $result -> {URL},
                    $result -> {Method},
                    $result -> {Response} || q{?},
                    $result -> {Length}
                );
            };
        }

        my $self = {
            builder => $builder
        };

        return $self;
    }
}

1;
