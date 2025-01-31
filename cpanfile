requires "Mojo::UserAgent";
requires "YAML::Tiny", "1.73";
requires "Find::Lib", "1.04";
requires "JSON", "4.07";
requires "IO::Interactive";

on 'test' => sub {
    requires "Test::More";
    requires "Test::MockModule";
};
