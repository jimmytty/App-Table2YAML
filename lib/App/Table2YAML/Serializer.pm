package App::Table2YAML::Serializer;

use common::sense;
use charnames q(:full);
use English qw[-no_match_vars];
use Scalar::Util qw[looks_like_number];
use List::Util qw[first];
use Moo;

# VERSION

has allow_nulls => (
    is      => q(rw),
    isa     => sub { $_[0] == 0 || $_[0] == 1 },
    default => 1,
);

sub serialize {
    my $self  = shift;
    my @table = splice @_;

    return unless @table;

    my @header = @{ shift @table };
    foreach (@header) { s{\A\p{IsSpace}+}{}msx; s{\p{IsSpace}+\z}{}msx; }

    my @yaml;
    while ( my $row = shift @table ) {
        my @row;
        while ( my ( $i, $header ) = each @header ) {
            my $data = $row->[$i];
            $data = $self->_serialize_scalar_data($data);
            next if !( $self->allow_nulls() ) && $data eq q(null);
            my %column = ( $header => $data );
            push @row, {%column};
        }
        if (@row) {
            my $yaml_record = $self->_serialize_row(@row);
            push @yaml, $yaml_record;
        }
    }

    return @yaml;
} ## end sub serialize

sub _serialize_row {
    my $self = shift;
    my @row  = splice @_;

    foreach my $column (@row) {
        $column = $self->_serialize_hash($column);
    }

    my $row = join qq(\N{COMMA}\N{SPACE}), @row;
    $row = sprintf q(- [ %s ]), $row;

    return $row;
}

sub _serialize_hash {
    my $self = shift;
    my %hash = %{ +shift };

    my @hash;
    while ( my ( $key, $value ) = each %hash ) {
        my $pair = join qq(\N{COLON}\N{SPACE}), $key, $value;
        push @hash, $pair;
    }

    my $hash = join qq(\N{COMMA}), @hash;
    $hash = sprintf q({%s}), $hash;

    return $hash;
} ## end sub _serialize_hash

sub _serialize_scalar_data {
    my $self = shift;
    my $data = shift;

    foreach ($data) {

        if ( !(defined) || $_ eq q() || m{^\p{IsSpace}+$}msx ) {
            $_ = q(null);
            last;
        }

        s{\A\p{IsSpace}+}{}msx;
        s{\p{IsSpace}+\z}{}msx;

        my $scalar_value = $self->_define_scalar_value($_);

        if ( $scalar_value eq q(string) ) {
            s{"}{\\"}gmsx;
            $_ = qq("$_");
        }
        elsif ( $scalar_value eq q(inf_or_nan) ) {
            s{^[+-]?\K}{.}msx;
        }

    } ## end foreach ($data)

    return $data;
} ## end sub _serialize_scalar_data

sub _define_scalar_value {
    my $self  = shift;
    my $value = shift;

    my $scalar_value;

    my $nv = looks_like_number($_);
    if ( $nv != 0 ) {
        if ( $nv == 36 ) {
            $scalar_value = q(inf_or_nan);
        }
        elsif ( $nv == 20 || $nv == 28 ) {
            if ( first { fc($value) eq $_ } qw[infinity -infinity +infinity] )
            {
                $scalar_value = q(string);
            }
            else { $scalar_value = q(inf_or_nan) }
        }
        else { $scalar_value = q(numeric); }
    }
    else {
        if ( first { fc($value) eq $_ } qw[y true yes on n false no off] ) {
            $scalar_value = q(boolean);
        }
        elsif ( first { fc($value) eq $_ } qw[~ null] ) {
            $scalar_value = q(null);
        }
        elsif ($value =~ m{^[+-]?0x[0-9A-F]+$}imsx
            || $value
            =~ m{^[+-]?(?:[0-9]{1,3})(?:_[0-9]{3})*(?:\.[0-9]+)?$}msx )
        {
            $scalar_value = q(numeric);
        }
        else { $scalar_value = q(string); }
    } ## end else [ if ( $nv != 0 ) ]

    return $scalar_value;
} ## end sub _define_scalar_value

no Moo;
__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Table2YAML::Serializer - Serialize Visual Table Data Structures into YAML.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

=head1 METHODS

=head2 serialize

Ronaldo Ferreira de Lima aka jimmy <jimmy at gmail>.

=cut
