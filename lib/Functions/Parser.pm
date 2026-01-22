package Functions::Parser {
	use strict;
	use warnings;
    use YAML::Tiny;

	sub new {
        my ($self, $workflow) = @_;

        if ($workflow) {
            my $yaml_file = YAML::Tiny -> read($workflow);
            my $workflow_rules = $yaml_file -> [0] -> {rules};

            return $workflow_rules;
        }
	}
}

1;
