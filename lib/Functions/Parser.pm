package Functions::Parser {
	use strict;
	use warnings;
    use YAML::Tiny;

	sub new {	
        my ($self, $workflow) = @_;

        my $yamlfile = YAML::Tiny -> read($workflow);
        my $rules = $yamlfile -> [0] -> {rules};

		return $rules;
	}
}

1;