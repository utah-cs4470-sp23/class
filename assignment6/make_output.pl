#!/usr/bin/perl -w

use strict;
use autodie;

my $JPLC = "/Users/johnregehr/compiler-class/pavpan/compile.py";

sub go($$) {
    (my $dir, my $flag) = @_;
    die unless -d $dir;
    my @files = glob "$dir/*.jpl";
    foreach my $f (@files) {
        system "$JPLC $flag $f";
    }
}

go("cf-tests", "--cf");
