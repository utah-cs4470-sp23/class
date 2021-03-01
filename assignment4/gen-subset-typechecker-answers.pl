#!/usr/bin/perl -w

use strict;

my $HOME = $ENV{"HOME"};

my $jdr_exe = "${HOME}/compiler-class/jdr/build/jplc";
my $pp_exe = "${HOME}/compiler-class/pavpan/compile.py";

my @files = ();
push @files, glob "tests/*.jpl";

foreach my $f (@files) {
    print "$f\n";
    {
        my $out = "$f.typechecked";
        my $cmd = "$jdr_exe -n -t $f | racket pp.rkt > $out";
        system $cmd;
    }
    {
        my $out = "$f.flattened";
        my $cmd = "$jdr_exe -f $f | racket pp.rkt > $out";
        system $cmd;
    }
    {
        my $out = "$f.s";
        my $cmd = "$pp_exe -s $f > $out";
        system $cmd;
    }
}
