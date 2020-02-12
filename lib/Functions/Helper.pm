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
		\r\t--url         Define target
		\r\t--wordlist    Define wordlist
		\r\t--return      Define a filter based in HTTP Code
		\r\t--exclude     Exclude determinates results based in HTTP Code
        \r\t--help        See this screen

		\rCopyright Fukon (c) 2020 | Heitor Gouvêa\n\n";
    
    return 1;
}

1;