package Functions::Helper {
	use strict;
	use warnings;

	sub new {
		print "
			\rNozaki v0.1.1
			\rCore Commands
			\r==============
			\r\tCommand       Description
			\r\t-------       -----------
            \r\t-A, --accept      Define a custom 'Accept' header
            \r\t-T, --tasks       The number of threads to run in parallel
            \r\t-H, --header      Define a custom header (header=value)
			\r\t-m, --method      Define methods HTTP to use during fuzzing, separeted by \",\"
			\r\t-u, --url         Define a target
			\r\t-w, --wordlist    Define wordlist of paths
			\r\t-d, --delay       Define a seconds of delay between requests
			\r\t-a, --agent       Define a custom User Agent
			\r\t-r, --return      Set a filter based on HTTP Code Response
			\r\t-t, --timeout     Define the timeout, default is 10s
			\r\t-p, --payload     Send a custom data
			\r\t-j, --json        Define the output in JSON format
			\r\t-h, --help        See this screen\n\n";
					
		return 1;
	}
}

1;