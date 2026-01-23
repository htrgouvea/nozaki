package Engine::FuzzerThread::ContentTypeFilters {
    use strict;
    use warnings;

    sub new {
        my ($class, %options) = @_;
        my @content_type_filters = ();

        if ($options{content_type_filter}) {
            @content_type_filters = split /,/x, $options{content_type_filter};
        }

        my $self = {
            content_type_filters => \@content_type_filters
        };

        return $self;
    }
}

1;
