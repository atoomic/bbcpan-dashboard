requires "Mojolicious"                            => 0;
requires "Mojo::Pg"                               => 0;
requires "Mojolicious::Plugin::DebugDumperHelper" => 0;
requires "Digest::SHA"                            => 0;

on "test" => sub {
    requires "Test2::Bundle::Extended"       => 0;
    requires "Test2::Plugin::NoWarnings"     => 0;
    requires "Test2::Suite"                  => 0;
    requires "Test2::Tools::Explain"         => 0;
    requires "Test::Mojo::Role::TestDeep"    => 0;
    requires "Test::Mojo::Role::Debug"       => 0;
    requires "Test::Mojo::Role::Debug::JSON" => 0;
    requires "Test::MockModule"              => 0;
    requires "File::Slurper"                 => 0;
    requires "File::Temp"                    => 0;
};
