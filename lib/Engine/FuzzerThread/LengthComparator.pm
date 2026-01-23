package Engine::FuzzerThread::LengthComparator {
    use strict;
    use warnings;

    sub new {
        my ($class, %options) = @_;
        my $length_filter = $options{length_filter};
        my $comparator;

        if ($length_filter) {
            my ($comparator_symbol, $filter_value)
                = $length_filter =~ /([>=<]{0,2})(\d+)/xms;
            if (!defined $comparator_symbol) {
                $comparator_symbol = q{};
            }
            if (!defined $filter_value) {
                $filter_value = 0;
            }

            if ($comparator_symbol eq '>=') {
                $comparator = sub { $_[0] >= $filter_value };
            }

            if ($comparator_symbol eq '<=') {
                $comparator = sub { $_[0] <= $filter_value };
            }

            if ($comparator_symbol eq '<>') {
                $comparator = sub { $_[0] != $filter_value };
            }

            if ($comparator_symbol eq '>') {
                $comparator = sub { $_[0] > $filter_value };
            }

            if ($comparator_symbol eq '<') {
                $comparator = sub { $_[0] < $filter_value };
            }

            if (!$comparator_symbol || $comparator_symbol eq q{=}) {
                $comparator = sub { $_[0] == $filter_value };
            }
        }

        my $self = {
            comparator => $comparator
        };

        return $self;
    }
}

1;
