package App::Table2YAML::CLI;

use common::sense;
use charnames q(:full);
use English qw[-no_match_vars];
use Moo;
use App::Table2YAML;

# VERSION

has opts    => ( is => q(rw), default => sub { {}; }, );
has errors  => ( is => q(rw), default => sub { []; }, );
has loaders => ( is => q(rw), default => sub { {}; }, );

sub BUILD {
    my $self = shift;

    $self->_get_loaders();

    return 1;
}

sub _get_loaders {
    my $self = shift;

    use App::Table2YAML::Loader;
    my $obj        = App::Table2YAML::Loader->new();
    my @method     = $obj->meta->get_method_list();
    my $prefix_str = q(load_);
    my $prefix_len = length($prefix_str);
    foreach my $method (@method) {
        next if substr( $method, 0, $prefix_len ) ne $prefix_str;
        my $loader = substr( $method, $prefix_len - length($method) );
        local $EVAL_ERROR;
        eval { $obj->$method() };
        my $status
            = defined $EVAL_ERROR
            && $EVAL_ERROR ne q()
            && index( $EVAL_ERROR, q(Unimplemented) ) + 1
            ? 0
            : 1;
        $self->loaders->{$loader} = $status;
    }

    return 1;
} ## end sub _get_loaders

sub parse_opts {
    my $self = shift;
    my %opt  = splice @_;

    foreach (q(list_loaders)) {
        if ( exists $opt{$_} ) {
            my $value = delete $opt{$_};
            if ( keys %opt ) {
                my $msg = qq('--$_' is incompatible with any other option);
                push @{ $self->errors() }, $msg;
                return 0;
            }
            else {
                $self->opts->{$_} = $value;
                return 1;
            }
        }
    }

    foreach (q(allow_nulls)) {
        last unless exists $opt{$_};
        my $value = delete $opt{$_};
        if ( $value == 0 || $value == 1 ) {
            $self->opts->{$_} = $value;
        }
        else {
            my $msg = qq(invalid value for '--$_': '$opt{$_}');
            push @{ $self->errors() }, $msg;
        }
    }

    foreach (q(input_type)) {
        if ( exists $opt{$_} ) {
            my $value = delete $opt{$_};
            if ( exists $self->loaders->{$value} ) {
                $self->opts->{$_} = $value;
            }
            else {
                my $msg = qq(invalid value for '--$_': '$opt{$_}' );
                push @{ $self->errors() }, $msg;
            }
        }
        else {
            my $msg = qq('--$_' is a mandatory option);
            push @{ $self->errors() }, $msg;
            return 0;
        }
    } ## end foreach (q(input_type))

    foreach (q(input)) {
        if ( exists $opt{$_} ) {
            my $value = delete $opt{$_};
            if ( -e -f $value ) {
                $self->opts->{$_} = $value;
            }
            else {
                my $msg = qq($opt{$_} isn't accessible);
                push @{ $self->errors() }, $msg;
            }
        }
        else {
            my $msg = qq('--input' is mandatory option);
            push @{ $self->errors() }, $msg;
            return 0;
        }
    } ## end foreach (q(input))

    my $parse = q(_parse_opts_) . $self->opts->{input_type};
    %opt = $self->$parse(%opt);

    foreach my $opt ( keys %opt ) {
        my $msg = qq(unknown option: '$opt');
        push @{ $self->errors() }, $msg;
    }

    return @{ $self->errors() } ? 0 : 1;
} ## end sub parse_opts

sub _parse_opts_asciitable {...}

sub _parse_opts_dsv {
    my $self = shift;
    my %opt  = splice @_;

    foreach (q(field_separator)) {
        if ( exists $opt{$_} ) {
            my $value = delete $opt{$_};
            $value = qq(\t) if $value eq q(\t);
            if ( length($value) == 1 ) {
                $self->opts->{$_} = $value;
            }
            else {
                my $msg = qq('--$_' need be only one character);
                push @{ $self->errors() }, $msg;
            }
        }
        else {
            my $msg = qq('--$_' is mandatory for '--input_type=dsv');
            push @{ $self->errors() }, $msg;
        }
    } ## end foreach (q(field_separator))

    foreach (q(record_separator)) {
        last unless exists $opt{$_};
        my %map = (
            q(\n)    => qq(\n),
            q(\r)    => qq(\r),
            q(\r\n)  => qq(\r\n),
            qq(\n)   => qq(\n),
            qq(\r)   => qq(\r),
            qq(\r\n) => qq(\r\n),
        );
        my $value = delete $opt{$_};
        if ( exists $map{$value} ) {
            $value = $map{$value};
            $self->opts->{$_} = $value;
        }
    } ## end foreach (q(record_separator))

    return %opt;
} ## end sub _parse_opts_dsv

sub _parse_opts_fixedwidth {...}
sub _parse_opts_html       {...}
sub _parse_opts_latex      {...}
sub _parse_opts_texinfo    {...}

sub table2yaml {
    my $self = shift;

    my $table2yaml = App::Table2YAML->new( $self->opts() );
    my @yaml       = $table2yaml->convert();

    return @yaml;
}

no Moo;
__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Table2YAML::CLI - Command Line Interface functions.

=head1 DESCRIPTION

=head1 METHODS

=head2 errors

=head2 loaders

=head2 opts

=head2 parse_opts

=head2 table2yaml

=head1 AUTHOR

Ronaldo Ferreira de Lima aka jimmy <jimmy at gmail>.

=for Pod::Coverage BUILD

=cut
