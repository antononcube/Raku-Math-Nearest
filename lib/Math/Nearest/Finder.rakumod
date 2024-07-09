use v6.d;

use Algorithm::KDimensionalTree;
use Math::Nearest::Scan;

class Math::Nearest::Finder does Callable {
    has $.finder;
    has $.method;

    #======================================================
    # Creators
    #======================================================
    submethod BUILD(:@points, :$distance-function = Whatever, :$method is copy = Whatever) {

        if $method.isa(Whatever) {
            $method = @points.all ~~ Str:D ?? 'Scan' !! 'KDTree';
        }

        die "The argument method is expected to be a string or Whatever"
        unless $method ~~ Str:D;

        given $method.lc {
            when $_ ∈ <kdtree k-d-tree k-dimensional-tree> {
                $!finder = Algorithm::KDimensionalTree.new(:@points, :$distance-function);
            }
            when $_ ∈ <scan> {
                $!finder = Math::Nearest::Scan.new(:@points, :$distance-function);
            }
            default {
                die "Unknown method specification. Known methods are 'KDTree' and 'Scan'.";
            }
        }
        $!method = $method;
    }

    multi method new(:@points, :$distance-function = Whatever, :$method is copy = Whatever) {
        self.bless(:@points, :$distance-function, :$method);
    }

    multi method new(@points, :$distance-function = Whatever, :$method is copy = Whatever) {
        self.bless(:@points, :$distance-function, :$method);
    }

    multi method new(@points, $distance-function = Whatever, :$method is copy = Whatever) {
        self.bless(:@points, :$distance-function, :$method);
    }

    #======================================================
    # CALL-ME
    #======================================================
    submethod CALL-ME(**@args, *%args) {
        return self.nearest(|@args, |%args);
    }

    #======================================================
    # Representation
    #======================================================
    method gist(){
        return "Math::Nearest::Finder({$!finder.gist})";
    }

    method Str(){
        return self.gist();
    }

    #======================================================
    # Top-level methods
    #======================================================
    proto method nearest($point, |) {*}

    multi method nearest($point where * !~~ Iterable:D, **@args, *%args) {
        # Should it be checked that @!points.head.elems == 1 ?
        return self.nearest([$point,], |@args, |%args);
    }

    multi method nearest(@point, UInt:D $count, :p(:$prop) = Whatever, Bool :$keys = False) {
        return self.nearest(@point, :$count, :$prop, :$keys);
    }

    multi method nearest(@point, Whatever, :p(:$prop) = Whatever, Bool :$keys = False) {
        return self.nearest(@point, count => 1, :$prop, :$keys);
    }

    multi method nearest(@point, ($count, $radius), :p(:$prop) = Whatever, Bool :$keys = False) {
        return self.nearest(@point, :$count, :$radius, :$prop, :$keys);
    }

    multi method nearest(@point, :c(:$count) = Whatever, :r(:$radius) = Whatever, :p(:$prop) is copy = Whatever, Bool :$keys is copy = False) {

        # Process properties
        my @knownProperties = <distance index label point>;

        if $prop.isa(Whatever) { $prop = <point>; }
        if $prop ~~ Str:D && $prop.lc eq 'all'  { $prop = @knownProperties; $keys = True; }
        if $prop ~~ Str:D { $prop = [$prop, ]; }

        die "The value of the argument property is expected to be Whatever or one of '{@knownProperties.join(',')}'."
        unless $prop ~~ Iterable:D && $prop.all ~~ Str:D && ($prop (-) @knownProperties).elems == 0;

        # Compute
        my @res = do given ($count, $radius) {
            when $_.head.isa(Whatever) && $_.tail.isa(Whatever) {
                $!finder.k-nearest(@point, 1, :!values);
            }
            when ( $_.head ~~ UInt:D && $_.tail.isa(Whatever) ) {
                $!finder.k-nearest(@point, $count, :!values);
            }
            when ( $_.head.isa(Whatever) && $_.tail ~~ Numeric:D ) {
                $!finder.nearest-within-ball(@point, $radius, :!values);
            }
            when ( $_.head ~~ UInt:D && $_.tail ~~ Numeric:D ) {
                my @res = $!finder.nearest-within-ball(@point, $radius, :!values);
                @res.sort(*<distance>)[^min($count, @res.elems)]
            }
            default {
                note 'The argument $count is expected to be a non-negative integer or Whatever. ' ~
                        'The argument $radius is expected to be a non-negative number of Whatever.';
                Nil
            }
        }

        # Result
        return do given $prop.sort {
            when <distance> {
                @res.map({ $_<distance> });
            }
            when <point> {
                return @res.map({ $_<point>.value });
            }
            when <index> {
                return @res.map({ $_<point>.key });
            }
            when <index point> {
                return @res.map({ ($_<point>.key, $_<point>.value) });
            }
            default {
                @res = @res.map({ %(distance => $_<distance>,
                                    index => $_<point>.key,
                                    point => $_<point>.value,
                                    label => $!finder.labels.elems ?? $!finder.labels[$_<point>.key] !! Whatever)
                });

                if $keys {
                    @res.map({ $prop.Array Z=> $_{|$prop}.Array })>>.Hash
                } else {
                    @res.map({ $_{|$prop} })
                }
            }
        }
    }
}

