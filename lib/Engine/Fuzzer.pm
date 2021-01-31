package Engine::Fuzzer {
    use strict;
    use warnings;
    use HTTP::Request;
    use LWP::UserAgent;

    sub new {
        my ($self, $agent, $timeout, $headers, $endpoint, $method, $payload, $accept) = @_;
        
        my $userAgent = LWP::UserAgent -> new (
            agent   => $agent,
            timeout => $timeout || 10,
            agent   => $agent,
        );

        my $request = HTTP::Request -> new($method, $endpoint);

        while (my ($header, $value) = each %{$headers}) {
            $request -> header($header => $value);
        }

        $request -> header(Accept => $accept) if $accept;
        $request -> content($payload) if $payload;

        my $response = $userAgent -> request($request);

        my $message  = $response -> message();
        my $length   = $response -> content_length() || "null";
        my $code     = $response -> code();
        my $content  = $response -> content();

        my $result = {
            "Code"     => $code,
            "URL"      => $endpoint,
            "Method"   => $method,
            "Response" => $message,
            "Length"   => $length 
        };

        return $result;
    }
}

1;