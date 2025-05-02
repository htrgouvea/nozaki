use strict;
use warnings;
use Test::More tests => 2;
use lib 'lib';
use Functions::Parser;
use YAML::Tiny;
use File::Temp 'tempfile';

my ($fh, $filename) = tempfile(SUFFIX => '.yml');
print $fh <<'EOF';
---
rules:
  - method: GET
    url: http://example.com
  - method: POST
    url: http://example.com/post
EOF
close $fh;

my $rules = Functions::Parser::new(undef, $filename);

is(ref($rules), 'ARRAY', 'Returned rules should be an array reference');
is(scalar @$rules, 2, 'Rules array should contain 2 elements');
