package Functions::Helper {
	use strict;
	use warnings;

	sub new {
        print "
            \rNozaki v0.3.0
            \rCore Commands
            \r==============
            \r\tCommand           Description
            \r\t-------           -----------
            \r\t-A, --accept      Define a custom 'Accept' header
            \r\t-T, --tasks       The number of threads to run concurrently, default is 30
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
            \r\t-j, --json        Display the results in JSON line format (one json object per line)
            \r\t-W, --workflow    Pass a YML file with a fuzzing workflow
            \r\t-S, --skip-ssl    Ignore SSL verification
            \r\t-l, --length      Filter by the length of content response 
            \r\t-c, --content     Filter by string based on the content response
            \r\t-P, --proxy       Send all requests through a proxy
            \r\t--report-to       Forward filtered results to a proxy (e.g., http://127.0.0.1:8080)
            \r\t--report-format   Format for --report-to: 'http' (default, forwards original request) or 'json' (sends request/response as JSON)
            \r\t-h, --help        See this screen\n\n";

		return 0;
	}
}

1;