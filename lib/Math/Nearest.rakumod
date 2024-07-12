use v6.d;

unit module Math::Nearest;

use Algorithm::KDimensionalTree;
use Math::Nearest::Scan;
use Math::Nearest::Finder;

#----------------------------------------------------------
# Find nearest elements.
proto nearest(|) is export {*}

multi sub nearest(@points, :$method = Whatever, :$distance-function = Whatever) {
    return  Math::Nearest::Finder.new(:@points, :$distance-function, :$method);
}

multi sub nearest(@points,
                  $search-point where * !~~ Iterable:D,
                  **@args, *%args) {
    return nearest(@points, [$search-point,], |@args, |%args);
}

multi sub nearest(@points,
                  @search-point,
                  UInt $count = 1,
                  :p(:$prop) = Whatever,
                  :$method = Whatever,
                  :$distance-function = Whatever) {
    my $finder = Math::Nearest::Finder.new(:@points, :$distance-function, :$method);
    return nearest($finder, @search-point, :$count, :$prop);
}

multi sub nearest(@points,
                  @search-point,
                  ($count, $radius),
                  :p(:$prop) = Whatever,
                  Bool :$keys = False,
                  :$method = Whatever,
                  :$distance-function = Whatever) {
    my $finder = Math::Nearest::Finder.new(:@points, :$distance-function, :$method);
    return $finder.nearest(@search-point, :$count, :$radius, :$prop, :$keys);
}

multi sub nearest(Math::Nearest::Finder:D $finder,
                  $search-point where * !~~ Iterable:D,
                  **@args, *%args) {
    return nearest($finder, [$search-point,], |@args, |%args);
}

multi sub nearest(Math::Nearest::Finder:D $finder,
                  @search-point,
                  ($count, $radius),
                  :p(:$prop) = Whatever,
                  Bool :$keys = False,
                  *%args) {
    # dummy %args
    return $finder.nearest(@search-point, :$count, :$radius, :$prop, :$keys);
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


#----------------------------------------------------------
# Gives the edges of a graph connecting each element to its nearest neighbors.
proto nearest-neighbor-graph(|) is export {*}

multi sub nearest-neighbor-graph(@points,
                                 :$method = Whatever,
                                 :$distance-function = Whatever,
                                 :$format = 'raku'
                                 ) {
    return nearest-neighbor-graph(@points, count => 1, :$distance-function, :$method, :$format);
}

multi sub nearest-neighbor-graph(@points, Whatever, *%args) {
    return nearest-neighbor-graph(@points, 1, |%args);
}

multi sub nearest-neighbor-graph(@points,
                                 UInt $count = 1,
                                 :$method = Whatever,
                                 :$distance-function = Whatever,
                                 :$format = 'raku'
                                 ) {
    return nearest-neighbor-graph(@points, :$count, :$distance-function, :$method, :$format);
}

multi sub nearest-neighbor-graph(@points,
                                 ($count, $radius),
                                 :$method = Whatever,
                                 :$distance-function = Whatever,
                                 :$format = 'raku'
                                 ) {
    return nearest-neighbor-graph(@points, :$count, :$radius, :$distance-function, :$method, :$format);
}

multi sub nearest-neighbor-graph(@points,
                                 :$count is copy = 1,
                                 :$radius = Whatever,
                                 :$method = Whatever,
                                 :$distance-function = Whatever,
                                 :$format = 'raku'
                                 ) {
    # Process points
    # This is done regardless in the finders, but we might issue additional messages here.
    my @labeledPoints = do given @points {
        when @points.all ~~ Pair:D { @points }
        when @points.all ~~ Iterable:D { @points.pairs }
        when @points.all ~~ Str:D { @points.map({ $_ => $_ }) }
        when @points.all !~~ Iterable:D { @points.map({ [$_,] }).pairs }
        default {
            die "The first argument is expected to be an array of pairs, an array of iterables, or an array of non-iterable objects.";
        }
    }

    # Process count
    $count = do given $count {
        when Numeric:D { $count + 1 }
        when $_.isa(Whatever) { ($radius ~~ Numeric:D) ?? Whatever !! 2 }
        default {
            die 'Do not know how to process the argument $count.';
        }
    }

    # Finder
    my &finder = nearest(@labeledPoints, :$distance-function, :$method);

    # Graph edges
    my @graph-edges =
            @labeledPoints.map({
                $_.key X=> &finder($_.value, :$count, :$radius, prop => <label>).tail(*-1).flat
            }).flat;

    # End result
    return do given $format {
        when $_ ~~ Str:D && $_.lc ∈ <mermaid memraid-js> {
            my $nns-graph = "graph TD\n" ~ @graph-edges.map({ "{ $_.key } --> { $_.value }" }).join("\n");
            $nns-graph
        }
        when $_ ~~ Str:D && $_.lc ∈ ['mathematica', 'wl', 'wolfram language'] {
            my $nns-graph =
                    ['Graph[{',
                     @graph-edges.map({ "DirectedEdge[\"{ $_.key }\", \"{ $_.value }\"]" }).join(", "),
                     '}, VertexLabels -> Automatic, ImageSize -> Large]'
                    ].join;
            $nns-graph
        }
        when $_ ~~ Str:D && $_.lc ∈ <dataset> {
            my @res = @graph-edges.map({ %(from => $_.key, to => $_.value) });
            @res
        }
        default {
            @graph-edges
        }
    }
}
