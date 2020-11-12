package Functions::Helper {
	use strict;
	use warnings;

	sub new {
		print "
			\rNozaki v0.0.10
			\rCore Commands
			\r==============
			\r\tCommand       Description
			\r\t-------       -----------
			\r\t--method      Define methods HTTP to use during fuzzing, separeted by \",\"
			\r\t--url         Define a target
			\r\t--wordlist    Define wordlist of paths
			\r\t--delay       Define a seconds of delay between requests
			\r\t--agent       Define a custom User Agent
			\r\t--return      Set a filter based on HTTP Code Response
			\r\t--timeout     Define the timeout, default is 10s
			\r\t--payload     Send a custom data
			\r\t--json        Define the output in JSON format
			\r\t--help        See this screen\n\n";
					
		return 1;
	}
}

1;