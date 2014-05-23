package App::Table2YAML::Loader;

use common::sense;
use charnames q(:full);
use Carp;
use English qw[-no_match_vars];
use Moo;
with qw[
    App::Table2YAML::Loader::AsciiTable
    App::Table2YAML::Loader::DSV
    App::Table2YAML::Loader::FixedWidth
    App::Table2YAML::Loader::HTML
    App::Table2YAML::Loader::LaTeX
    App::Table2YAML::Loader::Texinfo
];

has input => (
    is  => q(rw),
    isa => sub { @_ == 1 && -e $_[0] && -s $_[0] },
);
has input_type => ( is => q(rw), default => q(), );
has field_separator => (
    is  => q(rw),
    isa => sub { @_ == 1 && length $_[0] == 1 },
);
has record_separator => (
    is  => q(rw),
    isa => sub {
        @_ == 1 && $_[0] ~~ [
            qq(\N{CARRIAGE RETURN}),
            qq(\N{LINE FEED}),
            qq(\N{CARRIAGE RETURN}\N{LINE FEED}),
        ];
    },
    default => qq{\N{LINE FEED}},
);

sub BUILD {
    my $self = shift;
    my $args = shift;

    foreach my $arg ( keys %{$args} ) {
        if ( $self->can($arg) ) {
            $self->$arg( delete $args->{$arg} );
        }
    }

    return 1;
}

sub load {
    my $self = shift;

    if ( $self->input_type() ~~ [ undef, q() ] ) {
        croak(
            sprintf q(invalid input_type: '%s'),
            $self->input_type() // q(undef)
        );
    }

    my $loader = q(load_) . fc $self->input_type();
    my @table  = $self->$loader();

    return @table;
} ## end sub load

no Moo;
__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Table2YAML::Loader - ...

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 OPTIONS

=head1 ERRORS

=head1 DIAGNOSTICS

=head1 EXAMPLES

=head1 ENVIRONMENT

=head1 FILES

=head1 CAVEATS

=head1 BUGS

=head1 RESTRICTIONS

=head1 NOTES

=head1 AUTHOR

Ronaldo Ferreira de Lima aka jimmy <jimmy at gmail>.

=head1 HISTORY

=head1 COPYRIGHT AND LICENSE

=head1 SEE ALSO

=cut