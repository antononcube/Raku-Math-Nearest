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
```
# (Any)
```

### Set of points

Make a random set of points:

```perl6
my @points = ([(^100).rand, (^100).rand] xx 30).unique;
deduce-type(@points);
```
```
# Vector(Vector(Atom((Numeric)), 2), 30)
```

### Create the K-dimensional tree object

```perl6
my &finder = nearest(@points);

say &finder;
```
```
# Math::Nearest::Finder(Algorithm::KDimensionalTree(points => 30, distance-function => &euclidean-distance))
```

### Nearest k-neighbors

Use as a search point one from the points set:

```perl6
my @searchPoint = |@points.head;
```
```
# [82.7997137400612 51.815911977937425]
```

Find `4` nearest neighbors:

```perl6
my @res = &finder(@searchPoint, 4);
.say for @res;
```
```
# [82.7997137400612 51.815911977937425]
# [76.74690048700612 45.30314548421236]
# [93.76468756535048 53.45047592032191]
# [71.62175684954694 55.56128771507127]
```

Instead of using the "finder" object as a callable (functor) we can use `nearest`:

```perl6
.say for nearest(&finder, @searchPoint, count => 4)
```
```
# [82.7997137400612 51.815911977937425]
# [76.74690048700612 45.30314548421236]
# [93.76468756535048 53.45047592032191]
# [71.62175684954694 55.56128771507127]
```

Find nearest neighbors within a ball with radius `30`:

```perl6
.say for &finder(@searchPoint, (Whatever, 30))
```
```
# [93.76468756535048 53.45047592032191]
# [82.7997137400612 51.815911977937425]
# [68.66354164361587 52.25273427733615]
# [67.1439347976243 51.678609421192775]
# [76.74690048700612 45.30314548421236]
# [71.62175684954694 55.56128771507127]
# [58.6565707908774 67.61014125155556]
# [80.23300662613086 80.49154195793962]
# [82.92996945428985 71.0086509061165]
# [54.30669960433475 57.177447534448724]
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
```
# (data => * nns => ⏺ search => ▲)
# ++----------+-----------+----------+-----------+----------++       
# +                                                    *     + 100.00
# |                                                          |       
# |      *                                                   |       
# +*   *                      *    *   *         *           +  80.00
# |      *                                                   |       
# |    *                                          *          |       
# |                                 *                        |       
# +                               *                          +  60.00
# |                         *            ** ⏺     ▲     ⏺    |       
# |                                            ⏺             |       
# + *                                                        +  40.00
# |*   *                                                     |       
# |                                                          |       
# |                           *                              |       
# +                                               *          +  20.00
# |                       *                       *          |       
# |              *               *                           |       
# +                                                          +   0.00
# ++----------+-----------+----------+-----------+----------++       
#  0.00       20.00       40.00      60.00       80.00      100.00
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