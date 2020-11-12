package Engine::Fuzzer {
    use strict;
    use warnings;
    use JSON;
    use HTTP::Request;
    use LWP::UserAgent;

    sub new {
        my ($self, $method, $endpoint, $timeout, $delay, $agent, $return, $payload, $json) = @_;

        my $ua = LWP::UserAgent -> new (
            timeout => $timeout,
            agent => $agent
        );

        my @verbs = split(",", $method);

        foreach my $verb (@verbs) {
            my $request  = new HTTP::Request($verb, $endpoint);

            if ($payload) {
                # $request -> content_type("application/json"); # define the content-type
                $request -> content($payload);
            }

            my $response = $ua -> request($request);
            my $code     = $response -> code();
            my $message  = $response -> message();
            my $length   = $response -> content_length() || "null";

            my $printable = {
                "Code"     => $code,
                "URL"      => $endpoint,
                "Method"   => $verb,
                "Response" => $message,
                "Length"   => $length 
            };

            my $resultObject = encode_json ($printable);

            # Yeah, I know, i need refact that shit
            if ($return) { 
                if (@$printable{'Code'} == $return) {
                    if ($json) {
                        print $resultObject, "\n";
                    }

                    else {
                        print "Code: $code | URL: $endpoint | Method: [$verb] | Reponse: $message | Length: $length\n";
                    }     
                }
            }

            else {
                if ($json) {
                    print $resultObject, "\n";
                }

                else {
                    print "Code: $code | URL: $endpoint | Method: [$verb] | Response: $message | Length: $length\n";
                }   
            }

            sleep($delay);
        }

        return 1;
    }
}

1;