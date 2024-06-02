# Math::Nearest

Raku package for various algorithm for finding Nearest Neighbors (NNs)

The implementation is tested for correctness against Mathematica's [`Nearest`](https://reference.wolfram.com/language/ref/Nearest.html).
(See the resource files.)

### Features

- Finds both top-k Nearest Neighbors (NNs).
- Finds NNs within a ball with a given radius.
- Can return  distances, indexes, and labels for the found NNs.
    - The result shape is controlled with the option `:prop`.
- Works with arrays of numbers, arrays of arrays of numbers, and arrays of pairs.
- Utilizes distance functions from ["Math::DistanceFunctions"](https://github.com/antononcube/Raku-Math-DistanceFunctions).
    - Which can be specified by their string names, like, "bray-curtis" or "cosine-distance".
- Allows custom distance functions to be used.
- Currently has two algorithms (simple) Scan and K-Dimensional Tree (KDTree).

------

## Installation

From Zef ecosystem:

```
zef install Math::Nearest
```

From GitHub:

```
zef install https://github.com/antononcube/Raku-Math-Nearest.git
```

-----

## Usage examples

### Setup

```perl6
use Math::Nearest;
use Data::TypeSystem;
use Text::Plot;
```

### Set of points

Make a random set of points:

```perl6
my @points = ([(^100).rand, (^100).rand] xx 30).unique;
deduce-type(@points);
```

### Create the K-dimensional tree object

```perl6
my &finder = nearest(@points);

say &finder;
```

### Nearest k-neighbors

Use as a search point one from the points set:

```perl6
my @searchPoint = |@points.head;
```

Find `4` nearest neighbors:

```perl6
my @res = &finder(@searchPoint, 4);
.say for @res;
```

Instead of using the "finder" object as a callable (functor) we can use `nearest`:

```perl6
.say for nearest(&finder, @searchPoint, count => 4)
```

Find nearest neighbors within a ball with radius `30`:

```perl6
.say for &finder(@searchPoint, (Whatever, 30))
```

### Plot

Plot the points, the found nearest neighbors, and the search point:

```perl6
my @point-char =  <* ⏺ ▲>;
say <data nns search> Z=> @point-char;
say text-list-plot(
[@points, @res, [@searchPoint,]],
:@point-char,
x-limit => (0, 100),
y-limit => (0, 100),
width => 60,
height => 20);
```

-----

## TODO

- [ ] TODO Implementation
    - [ ] TODO Implement the Octree nearest neighbors algorithm.
    - [ ] TODO Make the nearest methods work with strings
        - For example, using Hamming distance over a collection of words.
        - Requires using the distance function as a comparator for the splitting hyperplanes.
        - This means, any objects can be used as long as they provide a distance function.
- [ ] TODO Documentation
    - [X] DONE Basic usage examples with text plots
    - [ ] TODO More extensive documentation with a Jupyter notebook
        - Using "JavaScript::D3".
    - [ ] TODO Corresponding blog post
    - [ ] MAYBE Corresponding video

-----

## References

[AAp1] Anton Antonov, [Math::DistanceFunctions Raku package](https://github.com/antononcube/Raku-Math-DistanceFunctions), (2024), [GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov, [Algorithm::KDimensionalTree Raku package](https://github.com/antononcube/Raku-Algorithm-KDimensionalTree), (2024), [GitHub/antononcube](https://github.com/antononcube).

[AAp3] Anton Antonov, [Data::TypeSystem Raku package](https://github.com/antononcube/Raku-Data-TypeSystem), (2023), [GitHub/antononcube](https://github.com/antononcube).

[AAp4] Anton Antonov, [Text::Plot Raku package](https://github.com/antononcube/Raku-Text-Plot), (2022), [GitHub/antononcube](https://github.com/antononcube).