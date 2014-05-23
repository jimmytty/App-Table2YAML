package App::Table2YAML::Loader::AsciiTable;

use common::sense;
use charnames q(:full);
use English qw[-no_match_vars];
use Moo::Role;

sub load_asciitable {...}

no Moo;
__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Table2YAML::Loader::AsciiTable - Plugin for I<ASCII> tables.

=head1 AUTHOR

Ronaldo Ferreira de Lima aka jimmy <jimmy at gmail>.

=cut
