#!/usr/bin/env perl

package Helper;

sub new {
	# \r\t--theards     Define number of theards, default is 3
	# \r\t--verbose     Set the verbose mode

	# --return
	# --exclude

    print "
        \rFukon v0.0.1
		\rCore Commands
		\r==============
		\r\tCommand       Description
		\r\t-------       -----------
		\r\t--url         Define target
		\r\t--wordlist    Define wordlist
		\r\t--return      Define a filter based in HTTP Codes
        \r\t--help        See this screen

		\rExamples
		\r==============

		\r $ perl fukon.pl -u https://api.spotify.com/v1/ --return 200,201

		\rCopyright Fukon (c) 2019 - 2020 | Heitor Gouvêa\n\n";
    
    return true;
}

1;