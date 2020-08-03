package Engine::Fuzzer {
    use strict;
    use warnings;
    use HTTP::Request;
    use LWP::UserAgent;

    sub new {
        my ($self, $method, $endpoint, $timeout, $delay, $agent, $return, $payload) = @_;

        my $ua = LWP::UserAgent -> new (
            timeout => $timeout,
            agent => $agent
        );

        my @verbs = split(",", $method);

        foreach my $verb (@verbs) {
            my $request  = new HTTP::Request($verb, $endpoint);

            if ($payload) {
                # $request -> content_type("application/json");
                $request -> content($payload);
            }

            my $response = $ua -> request($request);
            my $code     = $response -> code();
            my $message  = $response -> message();
            my $length   = $response -> content_length() || "null";

            if ($return) { # Yeah, I know, i need refact that shit
                if ($code == $return) {
                    print "[$code] | $endpoint \t [$verb] - $message | Length: $length\n";
                }
            }

            else {
                print "[$code] | $endpoint \t [$verb] - $message | Length: $length\n";
            }
            
            sleep($delay);
        }

        return 1;
    }
}

1;