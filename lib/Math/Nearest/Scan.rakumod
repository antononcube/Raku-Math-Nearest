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
    submethod BUILD(:@points, :$distance-function = 'euclidean-distance') {
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
        # If an array of arrays make it an array of pars
        if @!points.all ~~ Positional:D {
            @!points = @!points.pairs;
        } elsif @!points.all ~~ Pair:D {
            @!labels = @!points>>.key;
            @!points = @!points>>.value.pairs;
        } else {
            die "The points argument is expected to be an array of arrays or an array of pairs.";
        }
    }

    multi method new(:@points, :$distance-function = 'euclidean-distance') {
        self.bless(:@points, :$distance-function);
    }

    multi method new(@points, :$distance-function = 'euclidean-distance') {
        self.bless(:@points, :$distance-function);
    }

    multi method new(@points, $distance-function = 'euclidean-distance') {
        self.bless(:@points, :$distance-function);
    }

    #======================================================
    # Representation
    #======================================================
    method gist(){
        return "Math::Nearest::Scan(points => {@!points.elems}, distance-function => {$!distance-function.gist})";
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
    method k-nearest(@point, UInt $k = 1) {
        my @nns = @!points.map({ %( distance => self.distance-function.($_.value, @point), point => $_ ) });
        @nns = @nns.sort(*<distance>);
        return @nns[^min($k, @nns.elems)];
    }

    #======================================================
    # Nearest within a radius
    #======================================================
    method nearest-within-ball(@point, Numeric $r) {
        my @nns = @!points.map({ %( distance => self.distance-function.($_.value.Array, @point), point => $_ ) });
        @nns = @nns.grep({ $_<distance> ≤ $r });
        return @nns;
    }
}

