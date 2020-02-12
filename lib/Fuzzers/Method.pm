package Fuzzers::Method;

use strict;
use warnings;
use HTTP::Request;
use LWP::UserAgent;

sub new {
    my ($self, $endpoint, $return, $exclude) = @_;

    my $userAgent = LWP::UserAgent -> new();
    
    my $header = [
        "Accept" => "*/*",
        "Content-Type" => "*/*"
    ];

    my @verbs = (
        "GET", "POST", "PUT", "DELETE", "HEAD", "OPTIONS", "CONNECT", "TRACE", "PATCH", "SUBSCRIBE", "MOVE", 
        "REPORT", "UNLOCK", "%s%s%s%s", "PURGE", "POLL", "NOTIFY", "SEARCH", "1337", "JEFF", "CATS", 
        "*", "DATA", "HEADERS", "PRIORITY", "RST_STREAM", "SETTINGS", "PUSH_PROMISE", "PING",  "GOAWAY", "WINDOW_UPDATE", 
        "CONTINUATION"
    );

    foreach my $verb (@verbs) {
        my $request     = new HTTP::Request($verb, $endpoint, $header);
        my $response    = $userAgent -> request($request);
        my $httpCode    = $response -> code();
        my $httpMessage = $response -> message();

        # if ($exclude) {
        #     my @exclude = split(",", $exclude);

        #      foreach my $filter (@exclude) {
        #         if ($httpCode ne $filter) {
        #             print "[-] -> [$httpCode] | $endpoint \t [$verb] - $httpMessage\n";
        #         }
        #     }
        # }

        if ($return) {
            my @return = split(",", $return);

            foreach my $filter (@return) {
                if ($httpCode eq $filter) {
                    print "[-] -> [$httpCode] | $endpoint \t [$verb] - $httpMessage\n";
                }
            }
        }
        
        else {
            print "[-] -> [$httpCode] | $endpoint \t [$verb] - $httpMessage\n";
        }   
    }

    return 1;
}

1;