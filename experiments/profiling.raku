#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use Math::Nearest;
use Math::DistanceFunctions;

my @vecs = (^1000).map({ (^1000).map({1.rand}).cache.Array }).Array;
my @searchVector = (^1000).map({1.rand});

my $start = now;
my @dists = @vecs.map({ euclidean-distance($_, @searchVector)});
my $scan-vectors-time += now - $start;

$start = now;
my &finder = nearest(@vecs, method => 'Scan', distance-function => &euclidean-distance);
my $finder-creation-time += now - $start;

say "&finder.finder.distance-function : ", &finder.finder.distance-function.raku;


$start = now;
my @res = &finder(@searchVector, 12);
my $nns-finding-time = now - $start;

say "All distances time   : {$scan-vectors-time}s";
say "Finder creation time : {$finder-creation-time}s";
say "NNs finding time     : {$nns-finding-time}s";