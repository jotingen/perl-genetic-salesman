#!/usr/bin/env perl

use strict;
use warnings;

package Tour;

use File::Basename;
use lib dirname(__FILE__) . '/../perl/lib/perl5';
use lib dirname(__FILE__) . '/../perl/extlib/perl5';

use Data::Alias;
use Mouse;
use POSIX;
use Data::Dumper;

has order => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { [] }
);

has fitness => (
    is      => 'rw',
    default => 0
);

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    my $MUTATION_PROBABILTY = shift;
    my $CONCAT_PROBABILITY  = shift;

    if ( @_ != 2 ) {
        die("Needs two parents");
    }

    return $class->$orig(
        order => mutate(
            $MUTATION_PROBABILTY, concat( $CONCAT_PROBABILITY, $_[0], $_[1] )
        ),
    );
};

sub concat {
    my $CONCAT_PROBABILITY = shift;
    my $order_a            = shift;
    my $order_b            = shift;

    if ( int( rand(100) ) <= $CONCAT_PROBABILITY ) {
        my @rand;
        $rand[0] = int( rand( scalar @{$order_a} - 1 ) );
        $rand[1] = int( rand( scalar @{$order_a} - 1 ) );
        @rand    = sort @rand;
        my @new;
        foreach ( $rand[0] .. $rand[1] ) {
            $new[$_] = $order_a->[$_];
        }

        my $order_b_index = 0;
        foreach my $index ( 0 .. @{$order_b} - 1 ) {
            next if $index >= $rand[0] and $index <= $rand[1];

            while ( defined $order_b->[$order_b_index]
                and grep( { $order_b->[$order_b_index] eq $_ }
                    @new[ $rand[0] .. $rand[1] ] ) )
            {
                $order_b_index++;
            }

            $new[$index] = $order_b->[$order_b_index];
            $order_b_index++;
        }


        return \@new;
    }
    else {
        return $order_a;
    }
}

sub mutate {
    my $MUTATION_PROBABILTY = shift;
    my $order               = shift;

    if( int( rand(100) ) <= $MUTATION_PROBABILTY ) {

        my $rand1 = int( rand( scalar @{$order} - 1 ) );
        my $rand2 = int( rand( scalar @{$order} - 1 ) );

        alias @{$order}[ $rand1, $rand2 ] = @{$order}[ $rand2, $rand1 ];

        $order =  mutate(
            $MUTATION_PROBABILTY, $order);
    }
    return $order;
}

sub print {
    my $self = shift;

    my $s     = "";    #sprintf "%6d  |", distance($self);
    my $first = 1;
    foreach my $city ( @{ $self->{order} } ) {
        $s .= ',' unless $first;
        $s .= sprintf "%*d", log( scalar @{ $self->{order} } ) / log(10) + 1,
            $city;
        $first = 0;
    }

    return $s;
}

1;
