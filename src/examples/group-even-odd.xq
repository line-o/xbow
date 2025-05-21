xquery version '3.1';

import module namespace xbow = 'http://line-o.de/xq/xbow';

(:~
 : the shortest form to group by even and odd
 : the output will have numerical keys
~:)
declare function local:even-odd-with-numerical-keys ($item as xs:numeric) as xs:integer {
	$item mod 2
};

(: group by even and odd using a user provided function :)
(0 to 9) => xbow:groupBy(local:even-odd-with-numerical-keys#1),
	(: group by even and odd using the module function :)
	(0 to 9) => xbow:groupBy(xbow:even-odd#1),
	(: group by even and odd using the sum of each array :)
	([0, 1, 2], [3, 4, 5], [6, 7, 8], [9])
		=> xbow:groupBy(
			xbow:even-odd#1,
			function ($array as array(*)) {
				$array?* => sum()
			}
		),
	<ul>
    <li data="1">a</li>
    <li data="2">b</li>
    <li data="3">c</li>
    <li data="4">d</li>
</ul>
		=> xbow:pluck('li')
		=> xbow:groupBy(
			xbow:even-odd#1,
			function ($node as node()) {
				$node/@data => xs:integer()
			}
		),
	(:
  group by even and odd using the number property of each map
  by providing an accessor function
 :)
	(map {'number': 1}, map {'number': 2}, map {'number': 3}, map {'number': 4})
		=> xbow:groupBy(xbow:even-odd#1, xbow:pluck('number'))