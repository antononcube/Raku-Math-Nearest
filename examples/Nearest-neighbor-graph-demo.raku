#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use Data::Geographics;
use Data::Reshapers;
use Data::TypeSystem;
use Math::Nearest;
use Clipboard :ALL;

my @data = city-data().grep({ $_<Country> eq 'United States'});
@data = @data.grep({ -130 ≤ $_<Longitude> ≤ -60});
say @data.&dimensions;

my %locations = @data.grep({ $_<State> eq 'Nevada' && $_<Population> ≥ 10_000 }).map({ $_<ID> => $_<Latitude Longitude>});
%locations = %locations.map({ $_.key.subst('United_States.Nevada.','', :g).subst('.','_',:g) => $_.value });
say deduce-type(%locations);
say %locations.pick(3);


#say nearest-neighbor-graph(%locations.pairs, (Whatever, 3_000_000), distance-function => &geo-distance, format => 'wl');
nearest-neighbor-graph(%locations.pairs, 2, distance-function => &geo-distance, format => 'mermaid')
        ==> cbcopy() ==> say();