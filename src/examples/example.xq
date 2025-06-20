xquery version '3.1';

import module namespace xbow = 'http://line-o.de/xq/xbow';

(: using functions from external modules :)
(0 to 9)
	=> for-each(math:pow(?, 2))
	(: convert :)
	=> for-each(xs:string#1)
	=> for-each(xs:integer#1)
	=> for-each(xbow:to-array#1)
	=> for-each(xbow:to-sequence#1)
	(: filter by using a function returning a function :)
	=> filter(xbow:gt(10))
	(: all four lines below do the same thing, choose the one that fits you :)
	=> reverse()
	=> sort((), function ($a) { -$a })
	=> xbow:sortBy(function ($a) { -$a })
	=> xbow:ascending()
	(: group by even and odd :)

	(: => fold-left([], function ($result, $next) { :)
	(: let $rem := ($next mod 2) :)
	(: return array:put($result, $rem, ($result($rem), $next)) :)
	(: }) :)

	(: => fold-left(map{'even':(), 'odd':()}, function ($result, $next) { :)
	(: let $field := if ($next mod 2) then ('odd') else ('even') :)
	(: return map:put($result, $field, ($result($field), $next)) :)
	(: }) :)
	=> xbow:groupBy(xbow:even-odd#1)
	(: get a key from a map :)
	=> xbow:pluck('even')
	=> sum(),
(: returns 116 :)
(: return the first item in the reversed sequence as an integer :)
('1', '3', '2') => reverse() => xbow:take(1) => xs:integer()
(: returns 2 :)
