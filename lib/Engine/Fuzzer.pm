package Engine::Fuzzer;

use strict;
use warnings;
use HTTP::Request;
use LWP::UserAgent;

sub new {
    my ($self, $method, $endpoint, $delay) = @_;

    my $userAgent = LWP::UserAgent -> new();

    my @verbs = split(",", $method);

    foreach my $verb (@verbs) {
        my $request     = new HTTP::Request($verb, $endpoint);
        my $response    = $userAgent -> request($request);
        my $code    = $response -> code();
        my $message = $response -> message();
        my $length  = $response -> content_length() || "null";
        my $contentType = $response -> content_type();

        print "[-] -> [$code] | $endpoint \t [$verb] - $message | Length: $length\n"; 

        sleep($delay);
    }

    return 1;
}

1;