package Functions::Helper;

use strict;
use warnings;

sub new {
    print "
        \rNozaki v0.0.7
		\rCore Commands
		\r==============
		\r\tCommand       Description
		\r\t-------       -----------
		\r\t--url         Define a target
		\r\t--wordlist    Define wordlist of paths
		\r\t--method      Define methods HTTP to use during fuzzing, separeted by \",\"
		\r\t--delay       Define a seconds of delay between requests
		\r\t--maxtime     Define the timeout 
		\r\t--agent       Define a custom User Agent
		\r\t--return      Set a filter based on HTTP Code Response
		\r\t--help        See this screen\n\n";
    
    return 1;
}

1;