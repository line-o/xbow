xquery version "3.1";

module namespace xbow-spec="http://line-o.de/xbow/spec";
import module namespace xbow="http://line-o.de/xbow";

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

declare function xbow-spec:n-integer-accessor ($i) { xs:integer($i/@n) };

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
    %test:assertEquals(85)
function xbow-spec:nested-array-pluck () {
    $xbow-spec:nested-array
        => array:for-each(xbow:pluck(?,'n'))
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
    %test:assertEquals('11-11601893110')
function xbow-spec:distinct-values () {
    $xbow-spec:nested-array
        => xbow:to-sequence()
        => xbow:distinct-duplicates(function ($item) { $item?n })
        => xbow:pluck('distinct')
        => map:keys()
        => string-join()
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
    %test:assertEquals('<root><a>1</a><a>2</a><a>3</a><a>4</a><a>5</a><a>6</a></root>')
function xbow-spec:wrap-each () {
    (1 to 6) 
        => xbow:wrap-each('a')
        => xbow:wrap-element('root')
};

declare
    %test:assertEquals('<root><a>1</a><b>2</b></root>')
function xbow-spec:wrap-map-element () {
    map {
        'a': 1,
        'b': 2
    }
        => xbow:wrap-map-element()
        => xboq:wrap-element('root')

};

declare
    %test:assertEquals('<root a="1" b="2" />')
function xbow-spec:wrap-map-attribute () {
    map {
        'a': 1,
        'b': 2
    }
        => xbow:wrap-map-attribute()
        => xboq:wrap-element('root')
};

declare
    %test:assertEquals('a,b,h')
function xbow-spec:filter-map-keys () {
    $xbow-spec:map
        => xbow:filter-map-keys(('a', 'b', 'h'))
        => map:keys()
};

declare
    %test:assertEquals('1,10,11,-1,0,16,8,31,9')
function xbow-spec:map-reverse () {
    $xbow-spec:map
        => xbow:map-reverse()
        => map:keys()
};

declare
    %test:assertEquals('0,9,11,-2,-1,15,7,30,8')
function xbow-spec:map-reverse-function-add () {
    $xbow-spec:map
        => xbow:map-reverse(function ($k) {xs:int($k) - 1})
        => map:keys()
};

declare
    %test:assertEquals('xxxxxx-xxxx-xxxx-xxxxxxxxxxxxx')
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
