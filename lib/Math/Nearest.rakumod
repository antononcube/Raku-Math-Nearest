use v6.d;

unit module Math::Nearest;

use Algorithm::KDimensionalTree;
use Math::Nearest::Scan;
use Math::Nearest::Finder;

proto nearest(|) is export {*}

multi sub nearest(@points,
                  @search-point,
                  $count = 1,
                  :p(:$prop) = Whatever,
                  :$method = Whatever, :$distance-function = Whatever) {
    my $finder = Math::Nearest::Finder.new(:@points, :$distance-function, :$method);
    return nearest($finder, @search-point, :$count, :$prop);
}

multi sub nearest(Math::Nearest::Finder:D $finder,
                  @search-point,
                  :c(:$count) = Whatever,
                  :r(:$radius) = Whatever,
                  :p(:$prop) = Whatever,
                  Bool :$keys = False,
                  *%args) {
    return $finder.nearest(@search-point, :$count, :$radius, :$prop, :$keys);
}

