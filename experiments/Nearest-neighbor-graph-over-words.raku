#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use Data::Geographics;
use Data::Reshapers;
use Data::TypeSystem;
use Math::Nearest;
use Text::Levenshtein::Damerau;
use Clipboard :ALL;

my @words = "rachet", "racker", "racquet", "rackety", "raciness", "raceme", "racing", "racketeering", "racecard",
            "racketeer", "racecourse", "racial", "racy", "racist", "Rachmaninoff", "racily", "racemose", "racer",
            "rachitic", "racking", "raccoon", "Rachycentridae", "racism", "racquetball", "racially", "race", "Rachycentron",
            "racialism", "Racine", "Rachel", "rachischisis", "racket", "rachitis", "raceway", "racon", "racetrack",
            "racerunner", "racehorse", "racialist", "raceabout", "rack", "racketiness", "Rachmaninov", "racoon", "rachis", "raconteur";

nearest-neighbor-graph(@words, 2, distance-function => &dld, method => 'Scan', format => 'wl')
        ==> cbcopy() ==> say();