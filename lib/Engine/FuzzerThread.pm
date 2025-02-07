package Engine::FuzzerThread {
    use JSON;
    use strict;
    use threads;
    use warnings;
    use Engine::Fuzzer;
    use threads::shared;

    my $is_first_json_element :shared = 1;
    
    sub new {
        my (
            $self, $queue, $target, $methods, $agent, $headers, $accept,
            $timeout, $return, $payload, $json, $delay, $exclude, $skipssl,
            $length, $content, $proxy, $randomize_agent, $custom_agents
        ) = @_;
        
        my @verbs         = split (/,/, $methods);
        my @valid_codes   = split /,/, $return || "";
        my @invalid_codes = split /,/, $exclude || "";
        
        my $fuzzer = Engine::Fuzzer->new($timeout, $headers, $skipssl, $proxy);
        my $format = JSON->new()->allow_nonref()->pretty();

        my $cmp;
        
        if ($length) {
            ($cmp, $length) = $length =~ /([>=<]{0,2})(\d+)/;
            $cmp = sub { $_[0] >= $length } if ($cmp eq ">=");
            $cmp = sub { $_[0] <= $length } if ($cmp eq "<=");
            $cmp = sub { $_[0] != $length } if ($cmp eq "<>");
            $cmp = sub { $_[0] > $length  } if ($cmp eq  ">");
            $cmp = sub { $_[0] < $length  } if ($cmp eq  "<");
            $cmp = sub { $_[0] == $length } if (defined($cmp) || $cmp eq "=");
        }
        
        async {
            while (defined(my $resource = $queue->dequeue())) {
                my $endpoint = $target . $resource;
                my $found = 0;
                
                for my $verb (@verbs) {
               	   my $current_agent = $agent;
               	   
               	   if($randomize_agent) {
               	       require Functions::RandomizeAgent;
               	       $current_agent = Functions::RandomizeAgent::get_random_agent($custom_agents); 
               	   } 
                		
                    my $result = $fuzzer->request($verb, $agent, $endpoint, $payload, $accept);
                    
                    unless ($result) {
                        next;
                    }
                    
                    my $status = $result->{Code};
                    
                    if (scalar(grep { $_ eq $status } @invalid_codes)) {
                        next;
                    }
                    if ($return && !scalar(grep { $_ eq $status } @valid_codes)) {
                        next;
                    }
                    
                    if ($length && !($cmp->($result->{Length}))) {
                        next;
                    }
                    
                    $found = 1;
                    sleep($delay);
                    
                    my $output_handler = sub {
                        my ($result) = @_;
                        lock($is_first_json_element);
                        
                        my $json_str = $format->encode($result);
                        my $output = $is_first_json_element ? 
                            $json_str : 
                            ",\n$json_str";
                        
                        $is_first_json_element = 0;
                        return $output;
                    };
                    
                    my $plain_handler = sub {
                        my ($result) = @_;
                        return sprintf(
                            "Code: %d | URL: %s | Method: %s | Response: %s | Length: %s\n",
                            $status, $result->{URL}, $result->{Method},
                            $result->{Response} || "?", $result->{Length}
                        );
                    };
                    
                    my $handler = $json ? $output_handler : $plain_handler;
                    print $handler->($result);
                }
            }
        };
        
        return 1;
    }
}

1;
