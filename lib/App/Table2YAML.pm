package App::Table2YAML;

use common::sense;
use charnames q(:full);
use English qw[-no_match_vars];
use Moo;
use App::Table2YAML::Loader;
use App::Table2YAML::Serializer;

# VERSION

has loader => (
    is      => q(rw),
    default => sub { App::Table2YAML::Loader->new(); },
);
has serializer => (
    is      => q(rw),
    default => sub { App::Table2YAML::Serializer->new(); },
);

sub BUILD {
    my $self = shift;
    my $args = shift;

    foreach my $method ( keys %{$args} ) {
        foreach my $class (qw[loader serializer]) {
            if ( $self->$class->can($method) ) {
                my $value = delete $args->{$method};
                $self->$class->$method($value);
            }
        }
    }
    croak(q(unparsed args)) if %{$args};

    return 1;
} ## end sub BUILD

sub convert {
    my $self = shift;

    my @table = $self->loader->load();

    return unless @table;

    my @yaml = $self->serializer->serialize(@table);

    return @yaml;
}

no Moo;
__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Table2YAML - Convert the semantic of visual tables to I<YAML>.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 EXAMPLES

=head1 RESTRICTIONS

=head1 AUTHOR

Ronaldo Ferreira de Lima aka jimmy <jimmy at gmail>.

=head1 SEE ALSO

B<table2yaml> - Command Line Interface.

=cut
