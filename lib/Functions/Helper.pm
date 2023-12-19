package Functions::Helper {
	use strict;
	use warnings;

	sub new {
        print "
            \rNozaki v0.2.8
            \rCore Commands
            \r==============
            \r\tCommand           Description
            \r\t-------           -----------
            \r\t-A, --accept      Define a custom 'Accept' header
            \r\t-T, --tasks       The number of threads to run in parallel
            \r\t-H, --header      Define a custom header (header=value)
            \r\t-m, --method      Define HTTP methods to use during fuzzing, separeted by \",\"
            \r\t-u, --url         Define a target
            \r\t-w, --wordlist    Define wordlist of paths
            \r\t-d, --delay       Define seconds of delay between requests
            \r\t-a, --agent       Define a custom User Agent
            \r\t-r, --return      Set a filter based on HTTP Response Code
            \r\t-e, --exclude     Exclude a specific result based on HTTP Response Code
            \r\t-t, --timeout     Define the timeout, default is 10s
            \r\t-p, --payload     Send a custom data
            \r\t-j, --json        Display the results in JSON format
            \r\t-W, --workflow    Pass a YML file with a fuzzing workflow
            \r\t-S, --skip-ssl    Ignore SSL verification
            \r\t-l, --length      Filter by the length of content response 
            \r\t-c, --content     Filter by string based on the content response
            \r\t-h, --help        See this screen\n\n";

		return 0;
	}
}

1;