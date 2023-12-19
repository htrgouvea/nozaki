package Functions::Plugins {
    use strict;
    use warnings;

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