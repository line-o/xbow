xquery version "3.1";

import module namespace xbow = "http://line-o.de/xq/xbow";

declare
function local:item-plus-position ($item as xs:integer, $position as xs:integer) as xs:integer {
    $item + $position
};

xbow:for-each-index((0 to 4), local:item-plus-position#2),
xbow:for-each-index(array { (0 to 4) }, local:item-plus-position#2),

xbow:array-fill(4, true()),
xbow:array-fill(4, function ($ignore, $position as xs:positiveInteger) { xbow:lt($position * $position)})