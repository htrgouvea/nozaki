package Functions::Filter;

use strict;
use warnings;

sub new {
    my ($self, $return, $exclude) = @_;
    
    my %filter  = (
		"return" => "",
        "exclude"  => ""
    );

    if ($return) {
        $filter{return} = $return;
    }

    if ($exclude) {
        $filter{exclude} = $exclude;
    }
    
    return %filter;
}

1;