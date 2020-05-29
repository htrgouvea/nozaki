package Functions::Helper;

use strict;
use warnings;

sub new {
    print "
        \rNozaki v0.0.4
		\rCore Commands
		\r==============
		\r\tCommand       Description
		\r\t-------       -----------
		\r\t--url         Define a target
		\r\t--wordlist    Define wordlist of paths
		\r\t--method      Define methods HTTP to use during fuzzing, separeted by \",\"
		\r\t--delay       Define a seconds of delay between requests
		\r\t--maxtime     Define the timeout 
		\r\t--help        See this screen

		\rCopyright Nozaki (c) 2020 | Heitor Gouvêa\n\n";
    
    return 1;
}

1;