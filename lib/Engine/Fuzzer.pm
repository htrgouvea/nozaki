package Engine::Fuzzer {
    use strict;
    use warnings;
    use Try::Tiny;
    use Mojo::UserAgent;

    sub new {
        my ($self, $timeout, $headers, $skipssl) = @_;
        my $userAgent = Mojo::UserAgent -> new() -> request_timeout($timeout) -> insecure($skipssl);
        
        bless { 
            ua => $userAgent,
            headers => $headers 
        }, $self;
    }

    sub request {
        my ($self, $method, $agent, $endpoint, $payload, $accept) = @_;
       
        my $request = $self -> {ua} -> build_tx (
            $method => $endpoint => {
                'User-Agent' => $agent,
                %{$self -> {headers}}
            } => $payload || ""
        );
        
        try {
            my $response  = $self -> {ua} -> start($request) -> result();
            #use Data::Dumper;
            #print Dumper($response) if $response->is_redirect;
            my $message   = $response -> message;
            my $length    = $response -> headers -> content_length || "0";
            my $code      = $response -> code;
            my $content   = $response -> content;

            my $result = {
                "Code"     => $code,
                "URL"      => $endpoint,
                "Method"   => $method,
                "Response" => $message,
                "Length"   => $length,
                "RespURL"  => $response->is_redirect ? $response->headers->location : $endpoint
            };

            return $result;
        }

        catch {
            return undef;
        }
    }
}

1;
