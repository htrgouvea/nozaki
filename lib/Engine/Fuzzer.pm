package Engine::Fuzzer {
    use strict;
    use warnings;
    use Mojo::UserAgent;

    sub new {
        my ($self, $timeout, $headers, $skipssl) = @_;
        my $userAgent = Mojo::UserAgent -> new -> request_timeout($timeout) -> insecure($skipssl);
        bless { ua => $userAgent, headers => $headers }, $self;
    }

    sub request {
        my ($self, $method, $agent, $endpoint, $payload, $accept) = @_;
        my $request = $self -> {ua} -> build_tx (
            $method => $endpoint => {
                'User-Agent' => $agent,
                %{$self->{headers}}
            } => $payload || ""
        );

        my $response  = $self -> {ua} -> start($request) -> result;
        my $message   = $response -> message;
        my $length    = $response -> headers -> content_length || "0";
        my $code      = $response -> code;
        my $content   = $response -> content;

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