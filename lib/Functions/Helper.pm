package Functions::Helper;

use strict;
use warnings;

sub new {
    print "
        \rFukon v0.0.1
		\rCore Commands
		\r==============
		\r\tCommand       Description
		\r\t-------       -----------
		\r\t--url         Define a target
		\r\t--wordlist    Define wordlist of paths
		\r\t--header      Set a specific header
		\r\t--thread      Specific a number of threads
		\r\t--param       Fuzz for params
		\r\t--mime-type   Fuzz for mime type
		\r\t--method      Define methods to use during fuzzing
		\r\t--payload     Define a payload to send
		\r\t--return      Define a filter based in HTTP Code
		\r\t--exclude     Exclude determinates results based in HTTP Code
		\r\t--json        Create a output in JSON type supported by Postman
		\r\t--help        See this screen

		\rCopyright Fukon (c) 2020 | Heitor Gouvêa\n\n";
    
    return 1;
}

1;