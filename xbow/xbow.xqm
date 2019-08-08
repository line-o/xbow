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
    let $length := count($s)
  	return subsequence($s, $n, $length - $n)
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

(: group by :)

declare
function xbow:groupBy ($s as item()*, $key-function as function(*)) as map(*) {
    fold-left($s, map {}, function ($result as map(*), $item as item()) {
        let $key := $key-function($item)
        let $value := ($result($key), $item)
        return map:put($result, $key, $value)
    })
};

declare
function xbow:groupBy ($s as item()*, $key-function as function(*), $accessor as function(*)) as map(*) {
    fold-left($s, map {}, function ($result as map(*), $item as item()) {
        let $key := $key-function($accessor($item))
        let $value := ($result($key), $item)
        return map:put($result, $key, $value)
    })
};

declare
function xbow:even-odd ($item as xs:numeric) as xs:string {
  if ($item mod 2) then ('odd') else ('even')
};

(: accessor helper :)

declare
function xbow:pluck ($map as map(*), $field as xs:string) as item()* {
    $map($field)
};

declare
function xbow:pluck-deep ($map as map(*), $fields as xs:string*) as item()* {
    fold-left($fields, $map, xbow:pluck#2)
};


(: stats :)

declare variable $xbow:disdup-init := map {
    'distinct': map {}, 
    'duplicates': ()
};

declare function xbow:disdup-reducer ($result as map(), $next as xs:string) as map() {
    if (exists($result?distinct($next)))
    then (map:put($result, 'duplicates', ($result?duplicates, $next)))
    else (map:put($result, 'distinct', map:put($result?distinct, $next, true())))
};

declare function xbow:distinct-duplicates($s as item()*) as map() {
    fold-left($s, $xbow:disdup-init, xbow:disdup-reducer#2)
};

declare function xbow:distinct-duplicates($s as item()*, $accessor as function(*)) as map() {
    fold-left(for-each($s, $accessor(?)), $xbow:disdup-init, xbow:disdup-reducer#2)
};

declare
function xbow:sequence-stats-reducer ($result as map(*), $next as xs:numeric) as map(*) {
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

(: conversion helper functions :)

declare
function xbow:to-array ($sequence as item()*) as array(*) {
    array { $sequence }
};

declare
function xbow:to-sequence ($array as array(*)) as item()* {
    $array?*
};

(: comparison helper functions :)

declare
function xbow:ne ($comparison as item(), $accessor as function(*)) as function(*) {
    function ($i as item()) as xs:boolean { $accessor($i) ne $comparison }
};

declare
function xbow:ne ($comparison as item()) as function(*) {
    function ($i as item()) as xs:boolean { $i ne $comparison }
};

declare
function xbow:eq ($comparison as item(), $accessor as function(*)) as function(*) {
    function ($i as item()) as xs:boolean { $accessor($i) eq $comparison }
};

declare
function xbow:eq ($comparison as item()) as function(*) {
    function ($i as item()) as xs:boolean { $i eq $comparison }
};

declare
function xbow:gt ($comparison as item(), $accessor as function(*)) as function(*) {
    function ($i as item()) as xs:boolean { $accessor($i) gt $comparison }
};

declare
function xbow:gt ($comparison as item()) as function(*) {
    function ($i as item()) as xs:boolean { $i > $comparison }
};

declare
function xbow:ge ($comparison as item(), $accessor as function(*)) as function(*) {
    function ($i as item()) as xs:boolean { $accessor($i) >= $comparison }
};

declare
function xbow:ge ($comparison as item()) as function(*) {
    function ($i as item()) as xs:boolean { $i >= $comparison }
};

declare
function xbow:lt ($comparison as item(), $accessor as function(*)) as function(*) {
    function ($i as item()) as xs:boolean { $accessor($i) lt $comparison }
};

declare
function xbow:lt ($comparison as item()) as function(*) {
    function ($i as item()) as xs:boolean { $i lt $comparison }
};

declare
function xbow:le ($comparison as item(), $accessor as function(*)) as function(*) {
    function ($i as item()) as xs:boolean { $accessor($i) le $comparison }
};

declare
function xbow:le ($comparison as item()) as function(*) {
    function ($i as item()) as xs:boolean { $i le $comparison }
};

(:~ wrapping values in nodes ~:)

(:~
 : wrap item(s) in node with name $node-name
 : returns function that returns an element()
 : <$node-name>$item(s)</$node-name>
~:)
declare
function xbow:wrap-element ($name) {
    function ($value) { element { $name } { $value } }
};


(:~
 : wrap item(s) in attribute with name $attribute-name
 : returns function that returns an attribute()
 : multiple items will be joined into a single string separated by $joiner
~:)
declare
function xbow:wrap-attribute ($value as item()*, $attribute-name as xs:string, $joiner as xs:string) {
    attribute { $attribute-name } { string-join($value, $joiner) }
};

declare
function xbow:wrap-attribute ($value as item()*, $attribute-name as xs:string) {
    xbow:wrap-attribute($value, $attribute-name, ' ')
};

(:~
 : wrap each item(s) in node with name $node-name
 : returns function that returns a sequence of elements
(
   <$node-name>$item[1]</$node-name>,
   <$node-name>$item[1]</$node-name>,
   <$node-name>$item[1]</$node-name>
)
~:)
declare
function xbow:wrap-each ($values, $node-name as xs:string) {
    for-each($values, xbow:wrap-element($node-name))
};

declare
function xbow:wrap-map-attribute ($map as map(*)) {
    map:for-each($map, function ($k, $v) { attribute { $k } { $v } })
};

declare
function xbow:wrap-map-element ($map as map(*)) {
    map:for-each($map, function ($k, $v) { element { $k } { $v } })
};

declare
function xbow:map-filter-keys ($keys as xs:string*) {
    function ($map as map(*)) {
        for-each ($keys, function ($key) {
            map:entry($key, $map($key))
        })
        => map:merge()
    }
};