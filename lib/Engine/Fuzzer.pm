package Engine::Fuzzer {
    use strict;
    use warnings;
    use Try::Tiny;
    use Mojo::UserAgent;

    sub new {
        my ($self, $timeout, $headers, $skipssl, $content) = @_;

        my $userAgent = Mojo::UserAgent -> new() -> request_timeout($timeout) -> insecure($skipssl);

        bless {
            useragent => $userAgent,
            headers   => $headers
        }, $self;
    }

    sub request {
        my ($self, $method, $agent, $endpoint, $payload, $accept) = @_;

        my $request = $self -> {useragent} -> build_tx (
            $method => $endpoint => {
                "User-Agent" => $agent,
                %{$self -> {headers}}
            } => $payload || ""
        );

        try {
            my $response  = $self -> {useragent} -> start($request) -> result();

            my $result = {
                "Method"   => $method,
                "URL"      => $endpoint,
                "Code"     => $response -> code(),
                "Response" => $response -> message(),
                "Content"  => $response -> body(),
                "Length"   => $response -> headers() -> content_length() || "0"
            };

            return $result;
        }

        catch {
            return 0;
        }
    }
}

1; #