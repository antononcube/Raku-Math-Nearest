use v6.d;

use Math::DistanceFunctionish;
use Math::DistanceFunctions;

class Math::Nearest::Scan
        does Math::DistanceFunctionish {
    has @.points;
    has %.tree;
    has $.distance-function;
    has @.labels;

    #======================================================
    # Creators
    #======================================================
    submethod BUILD(:@points, :$distance-function = Whatever) {
        @!points = @points;
        given $distance-function {
            when $_.isa(Whatever) || $_.isa(WhateverCode) {
                $!distance-function = &euclidean-distance;
            }

            when $_ ~~ Str:D {
                $!distance-function = self.get-distance-function($_, :!warn);
                if $!distance-function.isa(WhateverCode) {
                    die "Unknown name of a distance function ⎡$distance-function⎦.";
                }
            }

            when $_ ~~ Callable {
                $!distance-function = $distance-function;
            }

            default {
                die "Do not know how to process the distance function spec.";
            }
        }

        # Process points
        # If an array of arrays make it an array of pairs
        if @!points.all !~~ Iterable:D {
            @!points = @!points.map({[$_, ]}).pairs;
        } elsif @!points.all ~~ Iterable:D {
            @!points = @!points.pairs;
        } elsif @!points.all ~~ Pair:D {
            @!labels = @!points>>.key;
            @!points = @!points>>.value.pairs;
        } else {
            die "The points argument is expected to be an array of arrays or an array of pairs.";
        }
    }

    multi method new(:@points, :$distance-function = Whatever) {
        self.bless(:@points, :$distance-function);
    }

    multi method new(@points, :$distance-function = Whatever) {
        self.bless(:@points, :$distance-function);
    }

    multi method new(@points, $distance-function = Whatever) {
        self.bless(:@points, :$distance-function);
    }

    #======================================================
    # Representation
    #======================================================
    multi method gist(::?CLASS:D:-->Str) {
        my $lblPart = @!labels.elems > 0 ?? ", labels => {@!labels.elems}" !! '';
        return "Math::Nearest::Scan(points => {@!points.elems}, distance-function => {$!distance-function.gist}" ~ $lblPart ~ ')';
    }

    method Str(){
        return self.gist();
    }

    #======================================================
    # Insert
    #======================================================
    multi method insert(@point) {
        my $new = Pair.new( @!points.elems, @point);
        @!points.push($new);
    }

    multi method insert(Pair:D $new) {
        @!points.push($new);
    }

    #======================================================
    # K-nearest
    #======================================================
    # The check where * !~~ Iterable:D is most like redundant.
    multi method k-nearest($point where * !~~ Iterable:D, UInt $k = 1, Bool :v(:$values) = True) {
        # Should it be checked that @!points.head.elems == 1 ?
        return self.k-nearest([$point,], $k, :$values);
    }

    multi method k-nearest(@point, UInt $k = 1, Bool :$values = True) {
        my @nns = @!points.map({ %( distance => self.distance-function.($_.value, @point), point => $_ ) });
        @nns = @nns.sort(*<distance>);
        @nns = @nns[^min($k, @nns.elems)];
        return $values ?? @nns.map(*<point>.value) !! @nns;
    }

    #======================================================
    # Nearest within a radius
    #======================================================
    multi method nearest-within-ball($point where * !~~ Iterable:D, Numeric $r, Bool :v(:$values) = True) {
        # Should it be checked that @!points.head.elems == 1 ?
        return self.nearest-within-ball([$point, ], $r, :$values);
    }

    multi method nearest-within-ball(@point, Numeric $r, Bool :$values = True) {
        my @nns = @!points.map({ %( distance => self.distance-function.($_.value.Array, @point), point => $_ ) });
        @nns = @nns.grep({ $_<distance> ≤ $r }).sort(*<distance>);
        return $values ?? @nns.map(*<point>.value) !! @nns;
    }
}

