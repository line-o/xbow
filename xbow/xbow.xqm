xquery version "3.1";

module namespace xbow="http://line-o.de/xbow";
import module namespace functx = "http://www.functx.com";

(:~
 : get the first $n items from sequence $s
 :
 : @param $s sequence of items
 : @param $n number of items to return
~:)
declare
function xbow:take ($s as item()*, $n as xs:integer) as item()* {
  	subsequence($s, 1, $n)
};

(:~
 : get the last $n items from sequence $s
 :
 : @param $s sequence of items
 : @param $n number of items to return
~:)
declare
function xbow:last ($s as item()*, $n as xs:integer) as item()* {
  	subsequence($s, 1, $n)
};


(:~
 : sort sequence $s by sorting function $f
 :
 : @param $s sequence of items
 : @param $f sorting function
~:)
declare
function xbow:sortBy ($s as item()*, $f as function(*)) as item()* {
    sort($s, (), $f)
};

declare
function xbow:ascending ($s as item()*) as item()* {
   xbow:sortBy($s, function ($a as xs:integer) { -$a })
};

declare
function xbow:descending ($s as item()*) as item()* {
   xbow:sortBy($s, function ($a as xs:integer) { $a })
};

declare
function xbow:groupBy ($s as map(*)*, $key-function as function(*)) {
    fold-left($s, map{}, function ($result, $item as item()) {
        let $key := $key-function($item)
        let $value := ($result($key), $item)
        return map:put($result, $key, $value)
    })
};

(: stats :)

declare
function xbow:pluck ($map as map(*), $field as xs:string) as item()* {
    $map($field)
};

declare
function xbow:pluck ($array as array(), $field as xs:string) as item()* {
    $array($field)
};

(: stats :)

declare function xbow:sequence-stats-reducer ($result as map(*), $next as xs:numeric) as map(*) {
    map {
        'min': min(($result?min, $next)),
		    'max': max(($result?max, $next)),
        'avg': ($result?sum + $next) div ($result?length + 1),
        'sum': $result?sum + $next,
        'length': $result?length + 1
	}
};

declare variable $xbow:initial-stats :=
    map { 'min': (), 'max': (), 'avg': 0.0, 'sum': 0, 'length': 0 };

declare function xbow:num-stats ($sequence as xs:numeric*) {
    fold-left($sequence, $xbow:initial-stats, xbow:sequence-stats-reducer#2)
};

(: filter helper functions :)

declare
function xbow:ne ($comparison as item()) as function(*) {
    function ($i as item()) as xs:boolean { $i ne $comparison }
};

declare
function xbow:eq ($comparison as item()) as function(*) {
    function ($i as item()) as xs:boolean { $i eq $comparison }
};

declare
function xbow:gt ($comparison as item()) as function(*) {
    function ($i as item()) as xs:boolean { $i > $comparison }
};

declare
function xbow:ge ($comparison as item()) as function(*) {
    function ($i as item()) as xs:boolean { $i >= $comparison }
};

declare
function xbow:lt ($comparison as item()) as function(*) {
    function ($i as item()) as xs:boolean { $i < $comparison }
};

declare
function xbow:le ($s as item()*, $idx as xs:integer) as function(*) {
    function ($i as item()) as xs:boolean { $i <= $comparison }
};
