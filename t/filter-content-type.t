use strict;
use warnings;
use Test::More tests => 6;
use Functions::ContentTypeFilter;

my @filters = ("application/json", "text/html");

ok(
    Functions::ContentTypeFilter::content_type_matches("application/json; charset=utf-8", \@filters),
    "matches json content type with charset"
);

ok(
    Functions::ContentTypeFilter::content_type_matches("TEXT/HTML", \@filters),
    "matches content type regardless of case"
);

ok(
    !Functions::ContentTypeFilter::content_type_matches("application/xml", \@filters),
    "does not match when content type is not in filters"
);

ok(
    !Functions::ContentTypeFilter::content_type_matches("", \@filters),
    "does not match empty content type"
);

ok(
    !Functions::ContentTypeFilter::content_type_matches("application/json", []),
    "does not match when filters are missing"
);

my @filters_with_empty = ("", "application/xml");

ok(
    Functions::ContentTypeFilter::content_type_matches("application/xml; charset=UTF-8", \@filters_with_empty),
    "matches when one valid filter is present"
);
