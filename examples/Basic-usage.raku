#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use Math::Nearest;
use Math::DistanceFunctions;
use Data::TypeSystem;
use Text::Plot;

my @points = ([(^100).rand, (^100).rand] xx 100).unique;

say deduce-type(@points);

my @searchPoint = |@points.head;
say (:@searchPoint);

# ========================================================================================================================
say "=" x 120;
say 'Nearest k-neighbors';
say "-" x 120;

my @res = nearest(@points, @searchPoint, 12);

say (:@res);
say 'elems => ', @res.elems;
say "Contains the search point: {[||] @res.map({ euclidean-distance(@searchPoint, $_) ≤ 0e-12 })}";

my @point-char =  <* ⏺ ø>;
say <data nns search> Z=> @point-char;
say text-list-plot(
        [@points, @res, [@searchPoint,]],
        :@point-char,
        x-limit => (0, 100),
        y-limit => (0, 100),
        width => 60,
        height => 20);