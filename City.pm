#!/usr/bin/env perl

use strict;
use warnings;

package City;

use File::Basename;
use lib dirname(__FILE__) . '/../perl/lib/perl5';
use lib dirname(__FILE__) . '/../perl/extlib/perl5';

use Mouse;

has x => (
    is => 'rw',
    default => 0
    );

has y => (
    is => 'rw',
    default => 0
    );

sub print {
    my $self = shift;

    printf "(%dx%d)", $self->{x}, $self->{y};

    }

1;
