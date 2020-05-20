package Engine::Fuzzer;

use strict;
use warnings;
use HTTP::Request;
use LWP::UserAgent;

sub new {
    my ($self, $method, $endpoint, $timeout, $delay) = @_;

    my $userAgent = LWP::UserAgent -> new(timeout => $timeout);

    my @verbs = split(",", $method);

    foreach my $verb (@verbs) {
        my $request  = new HTTP::Request($verb, $endpoint);
        my $response = $userAgent -> request($request);
        my $code     = $response -> code();
        my $message  = $response -> message();
        my $length   = $response -> content_length() || "null";

        print "[-] -> [$code] | $endpoint \t [$verb] - $message | Length: $length\n"; 

        sleep($delay);
    }

    return 1;
}

1;