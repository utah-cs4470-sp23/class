#!/usr/bin/perl -w

use strict;

my $HOME = $ENV{"HOME"};

my $jdr_exe = "${HOME}/compiler-class/jdr/build/jplc";
my $pp_exe = "${HOME}/compiler-class/pavpan/compile.py";

my @files = ();
push @files, glob "typechecker-tests/*.jpl";

foreach my $fn (@files) {
    print "$fn\n";
    open my $INF, "<$fn" or die;
    my $good = 0;
    my $bad = 0;
    while (my $line = <$INF>) {
        $good = 1 if ($line =~ /OK/);
        $bad = 1 if ($line =~ /ERROR/);
    }
    close $INF;
    die unless ($good + $bad) == 1;
    if ($good) {
        my $out = "${fn}.expected";
        my $cmd = "$jdr_exe -t ${fn} | racket pp.rkt > $out";
        system $cmd;
    }
}
