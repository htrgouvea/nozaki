package Engine::Fuzzer {
    use strict;
    use warnings;
    use Try::Tiny;
    use Mojo::UserAgent;

    our $VERSION = '0.0.3';

    sub new {
        my ($self, $timeout, $headers, $skipssl, $proxy) = @_;

        my $userAgent = Mojo::UserAgent -> new() -> request_timeout($timeout) -> insecure($skipssl);

        if ($proxy) {
            $userAgent -> proxy -> http($proxy);
            $userAgent -> proxy -> https($proxy);
        }

        bless {
            useragent => $userAgent,
            headers   => $headers
        }, $self;
    }

    sub request {
        my ($self, $method, $agent, $endpoint, $payload) = @_;

        my $headers = {
            'User-Agent' => $agent,
            %{$self -> {headers}}
        };

        my $request = $self -> {useragent} -> build_tx(
            $method => $endpoint => $headers => ($payload || q())
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

1;