package Functions::ContentTypeFilter {
    use strict;
    use warnings;

    our $VERSION = "0.3.1";

    sub content_type_matches {
        my ($content_type, $filters) = @_;

        if (!defined $content_type) {
            return 0;
        }

        if (!$content_type) {
            return 0;
        }

        if (!$filters) {
            return 0;
        }

        my $normalized_content_type = lc $content_type;
        my $match = 0;

        for my $filter (@{$filters}) {
            if (!defined $filter) {
                next;
            }

            if ($filter eq q{}) {
                next;
            }

            my $normalized_filter = lc $filter;

            if (index($normalized_content_type, $normalized_filter) >= 0) {
                $match = 1;
                last;
            }
        }

        return $match;
    }
}

1;
