package App::Table2YAML::Loader::Texinfo;

use common::sense;
use charnames q(:full);
use English qw[-no_match_vars];
use Moo::Role;

# VERSION

sub load_texinfo {...}

no Moo;
__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Table2YAML::Loader::Texinfo - Plugin for I<Texinfo> tables.

=head1 METHODS

=head2 load_texinfo

=head1 AUTHOR

Ronaldo Ferreira de Lima aka jimmy <jimmy at gmail>.

=cut
