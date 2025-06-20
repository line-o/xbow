xquery version '3.1';

module namespace xbow-spec = 'http://line-o.de/xbow/spec';

declare namespace test = 'http://exist-db.org/xquery/xqsuite';

import module namespace xbow = 'http://line-o.de/xq/xbow';

declare variable $xbow-spec:xml := <root>
	<a n='1' />
	<a n='3' />
	<a n='2' />
	<a n='16' />
	<a n='6' />
	<a n='11' />
	<a n='1' />
	<a n='23' />
	<a n='-1' />
	<a n='10' />
</root>;

declare variable $xbow-spec:nested-array := [
	map {'n': '1'},
	map {'n': '10'},
	map {'n': '11'},
	map {'n': '-1'},
	map {'n': '0'},
	map {'n': '16'},
	map {'n': '8'},
	map {'n': '31'},
	map {'n': '9'}
];

declare variable $xbow-spec:map := map {
	'a': '1',
	'b': '10',
	'c': '11',
	'd': '-1',
	'e': '0',
	'f': '16',
	'g': '8',
	'h': '31',
	'i': '9'
};

declare variable $xbow-spec:user-xml := <root>
	<user age="8" first="Susan" last="Young" />
	<user age="31" first="Ike" last="Hurst" />
	<user age="50" first="Marla" last="Hill" />
	<user age="41" first="Paula" last="Meyer" />
	<user age="72" first="Fela" last="Kuti" />
	<user age="123" first="Mike" last="Heiner" />
	<user age="53" first="Carla" last="Hill" />
	<user age="15" first="Chris" last="Christie" />
	<user age="41" first="Paula" last="Meyer" />
	<user age="34" first="Fela" last="Mack" />
</root>;

declare function xbow-spec:n-integer-accessor ($i as element()) as xs:integer {
	xs:integer($i/@n)
};

declare function xbow-spec:age-accessor ($i as element()) as xs:integer {
	xs:integer($i/@age)
};

(:~
 : declare
 : %test:assertTrue
 : function xbow-spec:lt-returns-function () {
 : xbow:lt(8) instance function()
 : };
 :)

declare %test:assertTrue function xbow-spec:lt-returns-boolean () {
	xbow:lt(8)(7)
};

declare %test:assertEquals(1) function xbow-spec:xml-filter-eq () {
	$xbow-spec:xml/a/@n/string() => filter(xbow:eq('23')) => count()
};

declare %test:assertEquals(8) function xbow-spec:xml-filter-ne () {
	$xbow-spec:xml/a/@n/string() => filter(xbow:ne('23')) => filter(xbow:ne('16')) => count()
};

declare %test:assertEquals(6) function xbow-spec:xml-filter-lt-accessor () {
	$xbow-spec:xml/a => filter(xbow:lt(8, xbow-spec:n-integer-accessor#1)) => count()
};

declare %test:assertEquals(6) function xbow-spec:xml-filter-le-accessor () {
	$xbow-spec:xml/a => filter(xbow:le(8, xbow-spec:n-integer-accessor#1)) => count()
};

declare %test:assertEquals(1) function xbow-spec:xml-filter-eq-accessor () {
	$xbow-spec:xml/a => filter(xbow:eq(23, xbow-spec:n-integer-accessor#1)) => count()
};

declare %test:assertEquals(8) function xbow-spec:xml-filter-ne-accessor () {
	$xbow-spec:xml/a
		=> filter(xbow:ne(23, xbow-spec:n-integer-accessor#1))
		=> filter(xbow:ne(16, xbow-spec:n-integer-accessor#1))
		=> count()
};

declare %test:assertEquals(4) function xbow-spec:array-filter-le-accessor () {
	$xbow-spec:nested-array
		=> array:filter(xbow:le(8, function ($i) { xs:integer($i?n) }))
		=> array:size()
};

declare %test:assertEquals('b') function xbow-spec:pluck-map () {
	map {'a': 'b'} => xbow:pluck('a')
};

declare %test:pending function xbow-spec:pluck-map-non-existent () {
	map {'a': 'b'} => xbow:pluck('c')
};

declare %test:assertEquals(2) function xbow-spec:pluck-array () {
	[1, 2] => xbow:pluck(2)
};

declare %test:assertEquals('a') function xbow-spec:filter-with-pluck () {
	(map {'a': 6}, map {'a': 16}) => filter(xbow:lt(8, xbow:pluck('a'))) => map:keys()
};

declare %test:assertEquals(85) function xbow-spec:nested-array-pluck () {
	$xbow-spec:nested-array
		=> array:for-each(xbow:pluck('n'))
		=> array:for-each(xs:integer(?))
		=> xbow:to-sequence()
		=> sum()
};

declare %test:assertEquals(5) function xbow-spec:group-by-even-odd () {
	(0 to 9) => xbow:groupBy(xbow:even-odd#1) => xbow:pluck('even') => count()
};

declare %test:assertEquals(4) function xbow-spec:xml-group-by-even-odd () {
	$xbow-spec:xml/a/@n/string()
		=> for-each(xs:integer#1)
		=> xbow:groupBy(xbow:even-odd#1)
		=> xbow:pluck('even')
		=> count()
};

declare %test:assertEquals(4) function xbow-spec:array-group-by-even-odd-accessor () {
	$xbow-spec:nested-array
		=> xbow:to-sequence()
		=> xbow:groupBy(xbow:even-odd#1, function ($element) { $element?n })
		=> xbow:pluck('even')
		=> count()
};

declare %test:assertEquals(1) function xbow-spec:pluck-deep () {
	map {'a': map {'b': map {'c': map {'d': map {'e': map {'f': 1}}}}}}
		=> xbow:pluck-deep(('a', 'b', 'c', 'd', 'e', 'f'))
};

declare %test:assertEquals(1) function xbow-spec:pluck-deep-array-in-map () {
	map {'a': ['1', map {'c': map {'d': map {'e': map {'f': 1}}}}]}
		=> xbow:pluck-deep(('a', 2, 'c', 'd', 'e', 'f'))
};

declare %test:assertEmpty function xbow-spec:pluck-deep-non-existent-field () {
	map {'a': map {'b': map {'c': map {'d': map {'e': map {'f': 1}}}}}}
		=> xbow:pluck-deep(('a', 'b', 'c', 1, 'd', 'e', 'f'))
};

declare %test:assertEquals(9) function xbow-spec:distinct-count () {
	$xbow-spec:xml/a/@n/string()
		=> xbow:distinct-duplicates()
		=> xbow:pluck('distinct')
		=> map:keys()
		=> count()
};

declare
	%test:assertEqualsPermutation('23', '16', '11', '3', '2', '1', '10', '6', '-1')
function xbow-spec:distinct-values-xml () {
	$xbow-spec:xml/a/@n/string() => xbow:distinct-duplicates() => xbow:pluck('distinct') => map:keys()
};

declare %test:assertEquals(1) function xbow-spec:duplicate-count () {
	$xbow-spec:xml/a/@n/string() => xbow:distinct-duplicates() => xbow:pluck('duplicates') => count()
};

declare %test:assertEquals('1') function xbow-spec:duplicate-values () {
	$xbow-spec:xml/a/@n/string()
		=> xbow:distinct-duplicates()
		=> xbow:pluck('duplicates')
		=> string-join()
};

declare %test:assertEquals(9) function xbow-spec:array-distinct-count () {
	$xbow-spec:nested-array
		=> xbow:to-sequence()
		=> xbow:distinct-duplicates(function ($item) { $item?n })
		=> xbow:pluck('distinct')
		=> map:keys()
		=> count()
};

declare
	%test:assertEqualsPermutation('11', '-1', '16', '0', '1', '8', '9', '31', '10')
function xbow-spec:distinct-values-array () {
	$xbow-spec:nested-array
		=> xbow:to-sequence()
		=> xbow:distinct-duplicates(function ($item) { $item?n })
		=> xbow:pluck('distinct')
		=> map:keys()
};

declare %test:assertEquals(0) function xbow-spec:array-duplicate-count-accessor () {
	$xbow-spec:nested-array
		=> xbow:to-sequence()
		=> xbow:distinct-duplicates(function ($item) { $item?n })
		=> xbow:pluck('duplicates')
		=> count()
};

declare %test:assertEquals('') function xbow-spec:array-duplicate-values-accessor () {
	$xbow-spec:nested-array
		=> xbow:to-sequence()
		=> xbow:distinct-duplicates(function ($item) { $item?n })
		=> xbow:pluck('duplicates')
		=> string-join()
};

declare %test:assertEquals('<a>1</a>') function xbow-spec:wrap () {
	1 => xbow:wrap-element('a')
};

declare
	%test:assertEquals('<a>1</a>', '<a>2</a>', '<a>3</a>', '<a>4</a>', '<a>5</a>', '<a>6</a>')
function xbow-spec:wrap-each () {
	(1 to 6) => xbow:wrap-each('a')
};

declare %test:assertTrue function xbow-spec:wrap-map-element () {
	map {'a': 1, 'b': 2}
		=> xbow:wrap-map-element()
		=> xbow:wrap-element('root')
		=> (function ($nodes as node()+) { $nodes/a/text() eq '1' and $nodes/b/text() eq '2' })()
};

declare %test:assertEquals('<root a="1" b="2" />') function xbow-spec:wrap-map-attribute () {
	map {'a': 1, 'b': 2} => xbow:wrap-map-attribute() => xbow:wrap-element('root')
};

declare %test:assertEqualsPermutation('a', 'b', 'h') function xbow-spec:map-filter-keys () {
	$xbow-spec:map => xbow:map-filter-keys(('a', 'b', 'h')) => map:keys()
};

declare %test:assertEquals('10000', '5', '3', '1', '0', '-1') function xbow-spec:descending () {
	(10000, -1, 5, 0, 1, 3) => xbow:descending()
};

declare %test:assertEquals('-1', '0', '1', '3', '5', '10000') function xbow-spec:ascending () {
	(10000, -1, 5, 0, 1, 3) => xbow:ascending()
};

declare
	%test:assertEquals('-1', '0', '1', '8', '9', '10', '11', '16', '31')
function xbow-spec:map-flip () {
	$xbow-spec:map => xbow:map-flip() => map:keys() => xbow:ascending()
};

declare
	%test:assertEquals('-2', '-1', '0', '7', '8', '9', '10', '15', '30')
function xbow-spec:map-flip-function-add () {
	$xbow-spec:map
		=> xbow:map-flip(function ($k) { xs:int($k) - 1 })
		=> map:keys()
		=> xbow:ascending()
};

declare
	%test:assertEquals('1f61f08a-04d5-3a9b-a749-7fad4d9b612c')
function xbow-spec:map-flip-function-uuid () {
	map {'key': 'value'} => xbow:map-flip(util:uuid(?)) => map:keys()
};

declare %test:assertEquals('55') function xbow-spec:map-flip-function-sum () {
	map {'key': (1 to 10)} => xbow:map-flip(sum(?)) => map:keys()
};

declare
	%test:args('()')
	%test:assertEquals('item()')
	%test:args('""')
	%test:assertEquals('xs:string')
	%test:args('1')
	%test:assertEquals('xs:integer')
	%test:args('1.2')
	%test:assertEquals('xs:decimal')
	%test:args('xs:date("1999-01-01")')
	%test:assertEquals('xs:date')
	%test:args('xs:QName("test:test")')
	%test:assertEquals('xs:QName')
	%test:args('attribute xml:id { "B" }')
	%test:assertEquals('attribute(xml:id)')
	%test:args('attribute id { "A" }')
	%test:assertEquals('attribute(id)')
	%test:args('element test:test { }')
	%test:assertEquals('element(test:test)')
	%test:args('element html { }')
	%test:assertEquals('element(html)')
	%test:args('comment { "no comment" }')
	%test:assertEquals('comment()')
	%test:args('text { "" }')
	%test:assertEquals('text()')
	%test:args('function () as xs:integer { 1 }')
	%test:assertEquals('function(*)')
	%test:args('function ($a as node()*) as xs:integer { count($a) }')
	%test:assertEquals('function(*)')
	%test:args('map{}')
	%test:assertEquals('map(*)')
	%test:args('map{"a": 1, 1: "a"}')
	%test:assertEquals('map(*)')
	%test:args('map{"a": "b"}')
	%test:assertEquals('map(xs:string, xs:string)')
	%test:args('map{"a": 12}')
	%test:assertEquals('map(xs:string, xs:integer)')
	%test:args('map{"a": 12, "b": ()}')
	%test:assertEquals('map(xs:string, *)')
	%test:args('map{1: 12, 2: ()}')
	%test:assertEquals('map(xs:integer, *)')
	%test:args('[]')
	%test:assertEquals('array(*)')
	%test:args('["a", "b"]')
	%test:assertEquals('array(xs:string)')
	%test:args('[map{}, map{}]')
	%test:assertEquals('array(map(*))')
function xbow-spec:get-type ($type) {
	util:eval('xbow:get-type(' || $type || ')')
};

declare %test:assertTrue function xbow-spec:all-true () {
	$xbow-spec:user-xml/user => xbow:all(xbow:ne(0, xbow-spec:age-accessor#1))
};

declare %test:assertTrue function xbow-spec:all-empty () {
	() => xbow:all(xbow:eq(1, xbow-spec:age-accessor#1))
};

declare %test:assertFalse function xbow-spec:all-false () {
	$xbow-spec:user-xml/user => xbow:all(xbow:lt(100, xbow-spec:age-accessor#1))
};

declare %test:assertFalse function xbow-spec:all-false2 () {
	$xbow-spec:user-xml/user => xbow:all(xbow:eq(2, xbow-spec:age-accessor#1))
};

declare %test:assertTrue function xbow-spec:none-true () {
	$xbow-spec:user-xml/user => xbow:none(xbow:eq(0, xbow-spec:age-accessor#1))
};

declare %test:assertFalse function xbow-spec:none-false () {
	$xbow-spec:user-xml/user => xbow:none(xbow:gt(100, xbow-spec:age-accessor#1))
};

declare %test:assertTrue function xbow-spec:none-empty () {
	() => xbow:none(xbow:eq(-1, xbow-spec:age-accessor#1))
};

declare %test:assertFalse function xbow-spec:none-false2 () {
	$xbow-spec:user-xml/user => xbow:none(xbow:ge(100, xbow-spec:age-accessor#1))
};

declare %test:assertTrue function xbow-spec:some-true () {
	$xbow-spec:user-xml/user => xbow:some(xbow:eq(41, xbow-spec:age-accessor#1))
};

declare %test:assertFalse function xbow-spec:some-empty () {
	() => xbow:some(xbow:eq(-1, xbow-spec:age-accessor#1))
};

declare %test:assertFalse function xbow-spec:some-false () {
	$xbow-spec:user-xml/user => xbow:some(xbow:eq(-1, xbow-spec:age-accessor#1))
};

declare %test:assertFalse function xbow-spec:some-false2 () {
	$xbow-spec:user-xml/user => xbow:some(xbow:eq(1000, xbow-spec:age-accessor#1))
};

declare %test:assertEquals(2) function xbow-spec:categorize-numbers () {
	(-10 to 10) => xbow:categorize([xbow:lt(0), xbow:ge(0)]) => array:size()
};

declare %test:assertEquals(0) function xbow-spec:categorize-none-match () {
	(0 to 10)
		=> xbow:categorize([xbow:lt(0), xbow:gt(10)])
		=> (function ($arr) { (count($arr?1), count($arr?2)) => sum() })()
};

declare %test:assertEquals(2) function xbow-spec:categorize-number-of-categories () {
	$xbow-spec:user-xml/user
		=> xbow:categorize([xbow:lt(21), xbow:ge(21)], xbow-spec:age-accessor#1)
		=> array:size()
};

declare %test:assertEquals('2', '8') function xbow-spec:categorize-number-of-items () {
	$xbow-spec:user-xml/user
		=> xbow:categorize([xbow:lt(21), xbow:ge(21)], xbow-spec:age-accessor#1)
		=> array:for-each(function ($items) { count($items) })
		=> xbow:to-sequence()
};

declare
	%test:assertEquals(
		'<user first=&quot;Susan&quot; last=&quot;Young&quot; age=&quot;8&quot;/>',
		'<user first=&quot;Chris&quot; last=&quot;Christie&quot; age=&quot;15&quot;/>'
	)
function xbow-spec:categorize-items () {
	$xbow-spec:user-xml/user
		=> xbow:categorize([xbow:lt(21), xbow:ge(21)], xbow-spec:age-accessor#1)
		=> (function ($arr) { $arr?1 })()
};

declare %test:assertEquals('underage', '2') function xbow-spec:label-categorized-items () {
	$xbow-spec:user-xml/user
		=> xbow:categorize([xbow:lt(21), xbow:ge(21)], xbow-spec:age-accessor#1)
		=> xbow:label(['underage', 'adult'])
		=> (function ($arr) { $arr?1?label, count($arr?1?items) })()
};

declare %test:assertTrue function xbow-spec:combine-for-each () {
	let $fna := string#1
	let $fnb := concat('-', ?, '-')
	let $d := (1.1, 'a', xs:date('1970-01-01'))

	let $r1 := $d => for-each(xbow:combine(($fna, $fnb)))
	let $r2 := $d => for-each($fna) => for-each($fnb)

	return $r1 = $r2
};

declare %test:assertFalse function xbow-spec:last-member-of-empty () {
	[] => xbow:last-member-of() => exists()
};

declare %test:assertEquals(9) function xbow-spec:last-member-of-range () {
	array { (1 to 9) } => xbow:last-member-of()
};

declare %test:assertFalse function xbow-spec:last-item-of-empty () {
	() => xbow:last-item-of() => exists()
};

declare %test:assertEquals(9) function xbow-spec:last-item-of-range () {
	(1 to 9) => xbow:last-item-of()
};

declare %test:assertFalse function xbow-spec:last-empty () {
	() => xbow:last() => exists()
};

declare %test:assertFalse function xbow-spec:last-empty-array () {
	[] => xbow:last() => exists()
};

declare %test:assertEquals(9) function xbow-spec:last-array () {
	array { (1 to 9) } => xbow:last()
};

declare %test:assertEquals(9) function xbow-spec:last-sequence () {
	(1 to 9) => xbow:last()
};

declare %test:assertEquals(1) function xbow-spec:last-item-is-array () {
	(1 to 9, [1]) => xbow:last() => array:get(1)
};
