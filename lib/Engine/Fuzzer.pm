package Engine::Fuzzer {
    use strict;
    use warnings;
    use Try::Tiny;
    use Mojo::UserAgent;

    our $VERSION = "0.3.1";

    sub new {
        my ($self, %options) = @_;

        my $user_agent = Mojo::UserAgent -> new()
            -> request_timeout($options{timeout})
            -> insecure($options{skipssl});

        if ($options{proxy}) {
            $user_agent -> proxy -> http($options{proxy});
            $user_agent -> proxy -> https($options{proxy});
        }

        my $instance = bless {
            user_agent => $user_agent,
            headers    => $options{headers} || {}
        }, $self;

        return $instance;
    }

    sub request {
        my ($self, %options) = @_;

        my %headers = (
            "User-Agent" => $options{agent},
            %{$self -> {headers}}
        );

        if ($options{accept}) {
            $headers{Accept} = $options{accept};
        }

        my $request = $self -> {user_agent} -> build_tx(
            $options{method} => $options{endpoint} => {
                %headers
            } => $options{payload} || q{}
        );

        my $result = try {
            my $response = $self -> {user_agent} -> start($request) -> result();

            my $content_type = $response -> headers() -> content_type();

            if (!$content_type) {
                $content_type = q{};
            }

            my $response_data = {
                "Method"   => $options{method},
                "URL"      => $options{endpoint},
                "Code"     => $response -> code(),
                "Response" => $response -> message(),
                "Content"  => $response -> body(),
                "Length"   => $response -> headers() -> content_length() || "0",
                "ContentType" => $content_type
            };

            return $response_data;
        }

        catch {
            return 0;
        };

        return $result;
    }
}

1;
