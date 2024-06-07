#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use Math::Nearest;
use Text::Levenshtein::Damerau;
use Data::TypeSystem;
use Data::Generators;

my $method = 'Scan';

# ========================================================================================================================
say "=" x 120;

my @points = (10.rand xx 100);

say deduce-type(@points);

my $finder = nearest(@points, :$method);

say $finder;

say nearest($finder, 2, (Whatever, 0.2));

# Alternatively, we can $finder as a Callable:
#say $finder(2, (Whatever, 0.2));

say nearest($finder, 2, radius => 0.2);

say $finder(2, 2);

# ========================================================================================================================
say "=" x 120;


#my @words = (('a'..'z').pick(5) xx 100)>>.join;
#my @words = random-pet-name(400).unique.grep({ $_.chars == 5 });
my @words = random-pet-name(120).unique;
my $searchWord = @words.head;

say deduce-type(@words);

my &finder2 = nearest(@words, distance-function => &dld, :$method);

say &finder2;

say "searchWord : $searchWord";

say nearest(&finder2, $searchWord, (Whatever, 3));

# Why this does not work:
#.say for nearest(&finder2, $searchWord, 8, prop => 'All');

# This works:
#.say for &finder2($searchWord, 8, prop => 'All');

# This also works:
.say for nearest(&finder2, $searchWord, count => 8, prop => 'All');

