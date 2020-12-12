package Functions::Utils {

    use strict;
    use warnings;
    use base 'Exporter';

    our @EXPORT = qw(url_info url_get_extension url_join);

    sub url_info {
        my ($url) = @_;
        my $scheme  = (split /:\/\//, $url)[0] . "://";
        my $domain  = (split /\//, substr($url, length($scheme)))[0];
        my $path    = substr($url, length($scheme) + length($domain)) || "/";
        my $file    = (split /\//, $path)[-1] || "";
        $path       = substr($path, 0, -length($file)) if $file;
        
        {
            scheme  => $scheme,
            domain  => $domain,
            path    => $path,
            file    => $file,
        }
    }

    sub url_join {
        my ($base, $res) = @_;
        ($base =~ /\/$/ || $res =~ /^\//) ? $base . $res : $base . "/" . $res
    }

    sub url_get_extension {
        my ($url) = @_;
        my $info = url_info($url);
        $info->{file} =~ /\./ ? (split /\./, $info->{file})[-1] : ""
    }
}

1;