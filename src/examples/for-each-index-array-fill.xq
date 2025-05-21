xquery version '3.1';

import module namespace xbow = 'http://line-o.de/xq/xbow';

declare function local:position-minus-item ($item as xs:integer, $position as xs:integer) as xs:integer {
	$position - $item
};

declare function local:lt-position-squared ($item as xs:integer, $position as xs:integer) as function(*) {
	xbow:lt($position * $position)
};

(: for-each-index examples with sequence and array :)
xbow:for-each-index((0 to 4), local:position-minus-item#2),
	xbow:for-each-index(
		array{
			(0 to 4)
		},
		local:position-minus-item#2
	),
	(: array-fill examples with constant value and callback function :)
	xbow:array-fill(4, true()),
	xbow:array-fill(4, local:lt-position-squared#2)