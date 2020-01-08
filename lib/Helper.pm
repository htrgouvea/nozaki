#!/usr/bin/env perl

package Helper;

sub new {
    print "
        \r\Fukon v0.0.1
		\r\Core Commands
		\r==============
		\r\tCommand       Description
		\r\t-------       -----------
		\r\t--url         Define the target
		\r\t--theards     Define number of theards, default is 3
		\r\t--wordlist    Define the wordlist
		\r\t--verbose     Set the verbose mode
        \r\t--help        See this screen

		\rCopyright Fukon (c) 2019 - 2020 | Heitor Gouvêa\n\n";
    
    return true;
}

1;