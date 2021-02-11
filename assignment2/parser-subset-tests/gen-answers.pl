#!/usr/bin/perl -w

use strict;

my $HOME = $ENV{"HOME"};

my $exe = "${HOME}/compiler-class/jdr/build/jplc";

my @files = ();
push @files, glob "ok/*.jpl";
push @files, glob "ok-fuzzer/*.jpl";

foreach my $f (@files) {
    print "$f\n";
    my $out = "$f.expected";
    my $cmd = "$exe -p $f | racket pp.rkt > $out";
    # print "$cmd\n";
    system $cmd;
}
