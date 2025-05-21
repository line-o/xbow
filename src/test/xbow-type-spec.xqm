xquery version '3.1';

module namespace xbow-type-spec = 'http://line-o.de/xbow/type-spec';
declare namespace test = 'http://exist-db.org/xquery/xqsuite';

import module namespace xbow = 'http://line-o.de/xq/xbow';

declare %test:assertEquals('function(*)', '1') function xbow-type-spec:lt-returns-function () {
	let $f := xbow:lt(8)
	return (xbow:get-type($f), function-arity($f))
};

declare %test:args('()')
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
	function xbow-type-spec:get-type ($type) {
	util:eval('xbow:get-type(' || $type || ')')
};



