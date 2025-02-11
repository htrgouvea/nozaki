package Functions::RandomizeAgent {
    use strict;
    use warnings;
    use List::Util qw(shuffle);
    
    my @default_agents = (
        "Nozaki / 0.2.9",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Safari/605.1.15",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/121.0" 
    );
    
    sub load_agents {
        my $file = shift;
        
        if($file && -e $file) {
            open my $fh, '<', $file or die "Cannot open $file: $!";
            chomp(my @agents = <$fh>);
            close $fh;
            return @agents if @agents; 
        }
        
        return @default_agents;
    }
    
    sub get_random_agent {
        my($file) = @_;
        my @agents = load_agents($file);
        return $agents[ int(rand(@agents)) ];
    }

}

1;
