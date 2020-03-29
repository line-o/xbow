xquery version "3.1";

module namespace xbow-spec="http://line-o.de/xbow/spec";


import module namespace xbow="http://line-o.de/xq/xbow";

declare namespace test="http://exist-db.org/xquery/xqsuite";

declare variable $xbow-spec:xml := 
    <root>
        <a n='1'/>
        <a n='3'/>
        <a n='2'/>
        <a n='16'/>
        <a n='6'/>
        <a n='11'/>
        <a n='1'/>
        <a n='23'/>
        <a n='-1'/>
        <a n='10'/>
    </root>;

declare variable $xbow-spec:nested-array := [
    map { 'n': '1' },
    map { 'n': '10' },
    map { 'n': '11' },
    map { 'n':'-1' },
    map { 'n': '0' },
    map { 'n': '16' },
    map { 'n': '8' },
    map { 'n': '31' },
    map { 'n': '9' }
];

declare variable $xbow-spec:map := map {
    'a': '1',
    'b': '10',
    'c': '11',
    'd':'-1',
    'e': '0',
    'f': '16',
    'g': '8',
    'h': '31',
    'i': '9'
};

declare variable $xbow-spec:user-xml :=
<root>
    <user first="Susan" last="Young" age="8"/>
    <user first="Ike" last="Hurst" age="31"/>
    <user first="Marla" last="Hill" age="50"/>
    <user first="Paula" last="Meyer" age="41"/>
    <user first="Fela" last="Kuti" age="72"/>
    <user first="Mike" last="Heiner" age="123"/>
    <user first="Carla" last="Hill" age="53"/>
    <user first="Chris" last="Christie" age="15"/>
    <user first="Paula" last="Meyer" age="41"/>
    <user first="Fela" last="Mack" age="34"/>
</root>
;

declare
function xbow-spec:n-integer-accessor ($i as element()) as xs:integer { xs:integer($i/@n) };

declare
function xbow-spec:age-accessor ($i as element()) as xs:integer { xs:integer($i/@age) };

(:~
declare 
    %test:assertTrue
function xbow-spec:lt-returns-function () {
    xbow:lt(8) instance function()
};
:)

declare 
    %test:assertTrue
function xbow-spec:lt-returns-boolean () {
    xbow:lt(8)(7)
};

declare 
    %test:assertEquals(6)
function xbow-spec:xml-filter-lt-accessor () {
    $xbow-spec:xml/a
        => filter(xbow:lt(8, xbow-spec:n-integer-accessor#1))
        => count()
};

declare 
    %test:assertEquals(6)
function xbow-spec:xml-filter-le-accessor () {
    $xbow-spec:xml/a
        => filter(xbow:le(8, xbow-spec:n-integer-accessor#1))
        => count()
};

declare 
    %test:assertEquals(1)
function xbow-spec:xml-filter-eq-accessor () {
    $xbow-spec:xml/a
        => filter(xbow:eq(23, xbow-spec:n-integer-accessor#1))
        => count()
};

declare 
    %test:assertEquals(1)
function xbow-spec:xml-filter-ne-string-accessor () {
    $xbow-spec:xml/a/@n/string()
        => filter(xbow:eq('23'))
        => count()
};

declare 
    %test:assertEquals(8)
function xbow-spec:xml-filter-ne-accessor () {
    $xbow-spec:xml/a
        => filter(xbow:ne(23, xbow-spec:n-integer-accessor#1))
        => filter(xbow:ne(16, xbow-spec:n-integer-accessor#1))
        => count()
};

declare 
    %test:assertEquals(8)
function xbow-spec:xml-filter-ne-string-accessor () {
    $xbow-spec:xml/a/@n/string()
        => filter(xbow:ne('23'))
        => filter(xbow:ne('16'))
        => count()
};


declare
    %test:assertEquals(4)
function xbow-spec:array-filter-le-accessor () {
    $xbow-spec:nested-array
        => array:filter(xbow:le(8, function ($i) { xs:integer($i?n) }))
        => array:size()
};

declare 
    %test:assertEquals('b')
function xbow-spec:pluck-map () {
    map { 'a': 'b'} => xbow:pluck('a')
};

declare 
    %test:pending
function xbow-spec:pluck-map-non-existent () {
    map { 'a': 'b'} => xbow:pluck('c')
};

declare 
    %test:assertEquals(2)
function xbow-spec:pluck-array () {
    [1, 2] => xbow:pluck(2)
};

declare 
    %test:pending
function xbow-spec:pluck-array () {
    [1, 2] => xbow:pluck(3)
};

declare 
    %test:assertEquals('a')
function xbow-spec:filter-with-pluck () {
    (
        map { 'a': 6 },
        map { 'a': 16 }
    )
        => filter(xbow:lt(8, xbow:pluck('a')))
        => map:keys()
};

declare 
    %test:assertEquals(85)
function xbow-spec:nested-array-pluck () {
    $xbow-spec:nested-array
        => array:for-each(xbow:pluck('n'))
        => array:for-each(xs:integer(?))
        => xbow:to-sequence()
        => sum() 
};

declare 
    %test:assertEquals(5)
function xbow-spec:group-by-even-odd () {
    (0 to 9)
        => xbow:groupBy(xbow:even-odd#1)
        => xbow:pluck('even')
        => count()
};

declare 
    %test:assertEquals(4)
function xbow-spec:xml-group-by-even-odd () {
    $xbow-spec:xml/a/@n/string()
        => for-each(xs:integer#1)
        => xbow:groupBy(xbow:even-odd#1)
        => xbow:pluck('even')
        => count()
};

declare 
    %test:assertEquals(4)
function xbow-spec:array-group-by-even-odd-accessor () {
    $xbow-spec:nested-array
        => xbow:to-sequence()
        => xbow:groupBy(xbow:even-odd#1, function ($element) { $element?n })
        => xbow:pluck('even')
        => count()
};

declare 
    %test:assertEquals(1)
function xbow-spec:pluck-deep () {
    map { 
        'a': map { 
            'b': map { 
                'c': map { 
                    'd': map { 
                        'e': map { 
                            'f': 1 
                        }
                    }
                }
            }
        }
    }
        => xbow:pluck-deep(('a','b','c','d','e','f'))
};


declare 
    %test:assertEquals(9)
function xbow-spec:distinct-count () {
    $xbow-spec:xml/a/@n/string()
        => xbow:distinct-duplicates()
        => xbow:pluck('distinct')
        => map:keys()
        => count()
};

declare 
    %test:assertEquals('1')
function xbow-spec:distinct-values () {
    $xbow-spec:xml/a/@n/string()
        => xbow:distinct-duplicates()
        => xbow:pluck('distinct')
        => map:keys()
        => string-join()
};

declare 
    %test:assertEquals(1)
function xbow-spec:duplicate-count () {
    $xbow-spec:xml/a/@n/string()
        => xbow:distinct-duplicates()
        => xbow:pluck('duplicates')
        => count()
};

declare 
    %test:assertEquals('1')
function xbow-spec:duplicate-values () {
    $xbow-spec:xml/a/@n/string()
        => xbow:distinct-duplicates()
        => xbow:pluck('duplicates')
        => string-join()
};

declare 
    %test:assertEquals(9)
function xbow-spec:array-distinct-count () {
    $xbow-spec:nested-array
        => xbow:to-sequence()
        => xbow:distinct-duplicates(function ($item) { $item?n })
        => xbow:pluck('distinct')
        => map:keys()
        => count()
};

declare 
    %test:assertEqualsPermutation('11','-1','16','0','1','8','9','31','10')
function xbow-spec:distinct-values () {
    $xbow-spec:nested-array
        => xbow:to-sequence()
        => xbow:distinct-duplicates(function ($item) { $item?n })
        => xbow:pluck('distinct')
        => map:keys()
};

declare 
    %test:assertEquals(0)
function xbow-spec:array-duplicate-count-accessor () {
    $xbow-spec:nested-array
        => xbow:to-sequence()
        => xbow:distinct-duplicates(function ($item) { $item?n })
        => xbow:pluck('duplicates')
        => count()
};

declare 
    %test:assertEquals('')
function xbow-spec:array-duplicate-values-accessor () {
    $xbow-spec:nested-array
        => xbow:to-sequence()
        => xbow:distinct-duplicates(function ($item) { $item?n })
        => xbow:pluck('duplicates')
        => string-join()
};

declare
    %test:assertEquals('<a>1</a>')
function xbow-spec:wrap () {
    1 => xbow:wrap-element('a')
};

declare
    %test:assertEquals('<a>1</a>','<a>2</a>','<a>3</a>','<a>4</a>','<a>5</a>','<a>6</a>')
function xbow-spec:wrap-each () {
    (1 to 6) 
        => xbow:wrap-each('a')
};

declare
    %test:assertTrue
function xbow-spec:wrap-map-element () {
    map {
        'a': 1,
        'b': 2
    }
        => xbow:wrap-map-element()
        => xbow:wrap-element('root')
        => (function ($nodes as node()+) {
            $nodes/a/text() eq '1' and
            $nodes/b/text() eq '2'
        })()
};

declare
    %test:assertEquals('<root a="1" b="2" />')
function xbow-spec:wrap-map-attribute () {
    map {
        'a': 1,
        'b': 2
    }
        => xbow:wrap-map-attribute()
        => xbow:wrap-element('root')
};

declare
    %test:assertEqualsPermutation('a','b','h')
function xbow-spec:map-filter-keys () {
    $xbow-spec:map
        => xbow:map-filter-keys(('a', 'b', 'h'))
        => map:keys()
};

declare
    %test:assertEquals('10000', '5', '3', '1', '0', '-1')
function xbow-spec:descending () {
    (10000, -1, 5, 0, 1, 3)
        => xbow:descending()
};

declare
    %test:assertEquals('-1', '0', '1', '3', '5', '10000')
function xbow-spec:ascending () {
    (10000, -1, 5, 0, 1, 3)
        => xbow:ascending()
};

declare
    %test:assertEquals('-1', '0', '1', '8', '9', '10', '11', '16', '31')
function xbow-spec:map-reverse () {
    $xbow-spec:map
        => xbow:map-reverse()
        => map:keys()
        => xbow:ascending()
};

declare
    %test:assertEquals('-2', '-1', '0', '7', '8', '9', '10', '15', '30')
function xbow-spec:map-reverse-function-add () {
    $xbow-spec:map
        => xbow:map-reverse(function ($k) {xs:int($k) - 1})
        => map:keys()
        => xbow:ascending()
};

declare
    %test:assertEquals('1f61f08a-04d5-3a9b-a749-7fad4d9b612c')
function xbow-spec:map-reverse-function-uuid () {
    map { 'key': 'value' }
        => xbow:map-reverse(util:uuid(?))
        => map:keys()
};

declare
    %test:assertEquals('55')
function xbow-spec:map-reverse-function-sum () {
    map { 'key': (1 to 10) }
        => xbow:map-reverse(sum(?))
        => map:keys()
};

declare
    %test:assertTrue
function xbow-spec:all-true () {
    $xbow-spec:user-xml/user
        => xbow:all(xbow:ne(0, xbow-spec:age-accessor#1))
};

declare
    %test:assertTrue
function xbow-spec:all-empty () {
    () => xbow:all(xbow:eq(1, xbow-spec:age-accessor#1))
};

declare
    %test:assertFalse
function xbow-spec:all-false () {
    $xbow-spec:user-xml/user
        => xbow:all(xbow:lt(100, xbow-spec:age-accessor#1))
};

declare
    %test:assertFalse
function xbow-spec:all-false2 () {
    $xbow-spec:user-xml/user
        => xbow:all(xbow:eq(2, xbow-spec:age-accessor#1))
};

declare
    %test:assertTrue
function xbow-spec:none-true () {
    $xbow-spec:user-xml/user
        => xbow:none(xbow:eq(0, xbow-spec:age-accessor#1))
};

declare
    %test:assertFalse
function xbow-spec:none-false () {
    $xbow-spec:user-xml/user
        => xbow:none(xbow:gt(100, xbow-spec:age-accessor#1))
};

declare
    %test:assertTrue
function xbow-spec:none-empty () {
    () => xbow:none(xbow:eq(-1, xbow-spec:age-accessor#1))
};

declare
    %test:assertFalse
function xbow-spec:none-false2 () {
    $xbow-spec:user-xml/user
        => xbow:none(xbow:ge(100, xbow-spec:age-accessor#1))
};

declare
    %test:assertTrue
function xbow-spec:some-true () {
    $xbow-spec:user-xml/user
        => xbow:some(xbow:eq(41, xbow-spec:age-accessor#1))
};

declare
    %test:assertFalse
function xbow-spec:some-empty () {
    () => xbow:some(xbow:eq(-1, xbow-spec:age-accessor#1))
};

declare
    %test:assertFalse
function xbow-spec:some-false () {
    $xbow-spec:user-xml/user
        => xbow:some(xbow:eq(-1, xbow-spec:age-accessor#1))
};

declare
    %test:assertFalse
function xbow-spec:some-false2 () {
    $xbow-spec:user-xml/user
        => xbow:some(xbow:eq(1000, xbow-spec:age-accessor#1))
};

declare
    %test:assertEquals(2)
function xbow-spec:categorize-numbers () {
    (-10 to 10)
        => xbow:categorize([ xbow:lt(0), xbow:ge(0) ])
        => array:size()
};

declare
    %test:assertEquals(0)
function xbow-spec:categorize-none-match () {
    (0 to 10)
        => xbow:categorize([ xbow:lt(0), xbow:gt(10) ])
        => (function ($arr) { (count($arr?1), count($arr?2)) => sum() })()
};

declare
    %test:assertEquals(2)
function xbow-spec:categorize-number-of-categories () {
    $xbow-spec:user-xml/user
        => xbow:categorize(
            [ xbow:lt(21), xbow:ge(21) ],
            xbow-spec:age-accessor#1
        )
        => array:size()
};

declare
    %test:assertEquals("2", "8")
function xbow-spec:categorize-number-of-items () {
    $xbow-spec:user-xml/user
        => xbow:categorize(
            [ xbow:lt(21), xbow:ge(21) ],
            xbow-spec:age-accessor#1
        )
        => array:for-each(function ($items) { count($items) })
        => xbow:to-sequence()
};

declare
    %test:assertEquals("<user first=&quot;Susan&quot; last=&quot;Young&quot; age=&quot;8&quot;/>","<user first=&quot;Chris&quot; last=&quot;Christie&quot; age=&quot;15&quot;/>")
function xbow-spec:categorize-number-of-items () {
    $xbow-spec:user-xml/user
        => xbow:categorize(
            [ xbow:lt(21), xbow:ge(21) ],
            xbow-spec:age-accessor#1
        )
        => (function ($arr) { $arr?1 })()
};

declare
    %test:assertEquals("underage", "2")
function xbow-spec:label-categorized-items () {
    $xbow-spec:user-xml/user
        => xbow:categorize(
            [ xbow:lt(21), xbow:ge(21) ],
            xbow-spec:age-accessor#1
        )
        => xbow:label(['underage', 'adult'])
        => (function ($arr) { $arr?1?label, count($arr?1?items) })()
};

declare
    %test:assertTrue
function xbow-spec:combine-for-each () {
    let $fna := string#1
    let $fnb := concat('-', ?, '-')
    let $d := (1.1, "a", xs:date('1970-01-01'))

    let $r1 := $d => for-each(xbow:combine(($fna, $fnb)))
    let $r2 := $d => for-each($fna) => for-each($fnb)

    return $r1 = $r2
};
