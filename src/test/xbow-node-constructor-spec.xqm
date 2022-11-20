xquery version "3.1";

module namespace xbow-node-constructor-spec="http://line-o.de/xbow/node-constructor-spec";


import module namespace xbow="http://line-o.de/xq/xbow";

declare namespace test="http://exist-db.org/xquery/xqsuite";

(: node constructors
 : these functions are inspired by a new standard proposed by Michael Kay
 :)

declare
    %test:assertEquals('<a href="http://line-o.de">My webpage</a>')
function xbow-node-constructor-spec:element () {
    xbow:element("a", (
        xbow:attribute("href", "http://line-o.de"),
        "My webpage"
    ))
};

declare
    %test:assertEquals('<svg xmlns="http://www.w3.org/2000/svg" viewbox="0 0 50 50"><path d="M 10 10 L 20 20 L 40 10 Z"/></svg>')
function xbow-node-constructor-spec:element-constructors () {
    let $svg := QName("http://www.w3.org/2000/svg", ?)
    let $fac := 10
    let $dim := (0, 0, 5 * $fac, 5 * $fac)
    let $points := [
        ("M", 1 * $fac, 1 * $fac), 
        ("L", 2 * $fac, 2 * $fac),
        ("L", 4 * $fac, 1 * $fac),
        "Z"
    ]

    return (
        xbow:attribute("viewbox", $dim, " "),
        xbow:element-ns($svg("path"), xbow:attribute("d", $points?*, " "))
    )
    => xbow:wrap-element($svg("svg"))
};


declare
    %test:assertEquals('<a>1</a>')
function xbow-node-constructor-spec:wrap () {
    1 => xbow:wrap-element('a')
};

declare
    %test:assertEquals('<a>1</a>','<a>2</a>','<a>3</a>','<a>4</a>','<a>5</a>','<a>6</a>')
function xbow-node-constructor-spec:wrap-each () {
    (1 to 6) 
        => xbow:wrap-each('a')
};

declare
    %test:assertTrue
function xbow-node-constructor-spec:wrap-map-element () {
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
function xbow-node-constructor-spec:wrap-map-attribute () {
    map {
        'a': 1,
        'b': 2
    }
        => xbow:wrap-map-attribute()
        => xbow:wrap-element('root')
};
