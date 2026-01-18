package Engine::Fuzzer {
    use strict;
    use warnings;
    use Try::Tiny;
    use Mojo::UserAgent;

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
        my ($self, $method, $agent, $endpoint, $payload, $accept) = @_;

        my $request = $self -> {useragent} -> build_tx (
            $method => $endpoint => {
                "User-Agent" => $agent,
                %{$self -> {headers}}
            } => $payload || ""
        );

        try {
            my $response  = $self -> {useragent} -> start($request) -> result();

            my $content_type = $response -> headers() -> content_type();

            if (!$content_type) {
                $content_type = "";
            }

            my $result = {
                "Method"   => $method,
                "URL"      => $endpoint,
                "Code"     => $response -> code(),
                "Response" => $response -> message(),
                "Content"  => $response -> body(),
                "Length"   => $response -> headers() -> content_length() || "0",
                "ContentType" => $content_type
            };

            return $result;
        }

        catch {
            return 0;
        }
    }
}

1;
