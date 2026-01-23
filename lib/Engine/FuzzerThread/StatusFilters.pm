package Engine::FuzzerThread::StatusFilters {
    use strict;
    use warnings;

    sub new {
        my ($class, %options) = @_;

        my @valid_codes = split /,/xms, $options{return} || q{};
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

        my $has_valid_codes = 0;

        if ($options{return}) {
            $has_valid_codes = 1;
        }

        my $self = {
            valid_code_lookup   => \%valid_code_lookup,
            invalid_code_lookup => \%invalid_code_lookup,
            has_valid_codes     => $has_valid_codes
        };

        return $self;
    }
}

1;
