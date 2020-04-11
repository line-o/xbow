xquery version "3.1";


import module namespace xbow = 'http://line-o.de/xq/xbow';

declare
function local:from-to ($from as xs:integer, $to as xs:integer) as xs:integer+ { 
    ($from to $to)
};

(
    xbow:combine((
        function ($n) { (1, $n) },
        local:from-to#2,
        sum#1,
        function ($n) { map { 'value': $n } }
    ))(10),
    xbow:combine((
        local:from-to#2,
        sum#1,
        function ($n) { map { 'value': $n } }
    ))((1, 10)),
    xbow:combine((
        sum#1,
        function ($n) { $n + 1 }
    ))((2, 3)),
    xbow:combine((
        array:filter(?, function ($n) { $n > 0 }),
        xbow:to-sequence(?)
    ))([1, 19, -1]),
    xbow:combine((
        sum#1,
        local:from-to(1, ?)
    ))((1 to 10))
)