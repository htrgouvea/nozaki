package Engine::Fuzzer {
    use strict;
    use warnings;
    use Try::Tiny;
    use Mojo::UserAgent;

    sub new {
        my ($self, $timeout, $headers, $skipssl, $proxy) = @_;

        my $user_agent = Mojo::UserAgent -> new() -> request_timeout($timeout) -> insecure($skipssl);

        if ($proxy) {
            $user_agent -> proxy -> http($proxy);
            $user_agent -> proxy -> https($proxy);
        }

        my $instance = bless {
            user_agent => $user_agent,
            headers    => $headers
        }, $self;

        return $instance;
    }

    sub request {
        my ($self, $method, $agent, $endpoint, $payload, $accept) = @_;

        my $request = $self -> {user_agent} -> build_tx (
            $method => $endpoint => {
                "User-Agent" => $agent,
                %{$self -> {headers}}
            } => $payload || ""
        );

        try {
            my $response = $self -> {user_agent} -> start($request) -> result();

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

        return 0;
    }
}

1;
