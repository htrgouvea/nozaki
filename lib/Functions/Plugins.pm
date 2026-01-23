package Functions::Plugins {
    use strict;
    use warnings;

    our $VERSION = '0.3.1';

    sub new {
        my ($self) = @_;

        if ($self) {
            print "Hello World!\n";

            return 1;
        }

        return 0;
    }
}

1;