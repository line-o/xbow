xquery version '3.1';

(:~ 
 : 
 : @author Juri Leino
~:)

module namespace xbow = 'http://line-o.de/xq/xbow';
(: Saxon does not declare map and array namespaces by default :)
declare namespace map = 'http://www.w3.org/2005/xpath-functions/map';
declare namespace array = 'http://www.w3.org/2005/xpath-functions/array';

(:~
 : get the first $n items from sequence $s
 :
 : @param $s sequence of items
 : @param $n number of items to return
~:)
declare function xbow:take ($s as item()*, $n as xs:integer) as item()* {
	subsequence($s, 1, $n)
};

(:~
 : get the last $n items from sequence $s
 :
 : @param $s sequence of items
 : @param $n number of items to return
~:)
declare function xbow:last ($s as item()*, $n as xs:integer) as item()* {
	subsequence($s, $n, count($s) - $n)
};

declare function xbow:items-at ($s as item()*, $n as xs:integer*) as item()* {
	for-each($n, subsequence($s, ?, 1))
};

(:~
 : sort sequence $s by sorting function $f
 :
 : @param $s sequence of items
 : @param $f sorting function
~:)
declare function xbow:sortBy ($s as item()*, $f as function(*)) as item()* {
	sort($s, (), $f)
};

declare function xbow:ascending ($s as item()*) as item()* {
	xbow:sortBy(
		$s,
		function ($a as item()) {
			xs:integer($a)
		}
	)
};

declare function xbow:descending ($s as item()*) as item()* {
	xbow:sortBy(
		$s,
		function ($a as item()) {
			xs:integer(-$a)
		}
	)
};

(: group by :)

declare function xbow:groupBy ($s as item()*, $key-function as function(*)) as map(*) {
	fold-left(
		$s,
		map {},
		function ($result as map(*), $item as item()) {
			let $key := $key-function($item)
			let $value := ($result($key), $item)
			return map:put($result, $key, $value)
		}
	)
};

declare function xbow:groupBy ($s as item()*, $key-function as function(*), $accessor as function(*)) as map(*) {
	fold-left(
		$s,
		map {},
		function ($result as map(*), $item as item()) {
			let $key := $key-function($accessor($item))
			let $value := ($result($key), $item)
			return map:put($result, $key, $value)
		}
	)
};

declare function xbow:even-odd ($item as xs:numeric) as xs:string {
	if ($item mod 2) then (
		'odd'
	) else (
		'even'
	)
};

(: sequence tests :)

(:~ 
 : Returns true if all items in the given $sequence
 : return true for the $comparison-function
 :
 : Example
 :   <code>xbow:all((1,2,3), function ($i) { $i < 5 })</code>
 :
 : Returns
 :   <code>true()</code>
 :)
declare function xbow:all ($sequence as item()*, $comparison-function as function(*)) as xs:boolean {
	fold-left(
		$sequence,
		true(),
		function ($result as xs:boolean, $next as item()) as xs:boolean {
			$result and $comparison-function($next)
		}
	)
};

(:~ 
 : Returns true if none of the items in the given $sequence
 : return true for the $comparison-function
 :
 : Example
 :   <code>xbow:none((1,2,3), function ($i) { $i > 5 })</code>
 :
 : Returns
 :   <code>true()</code>
 :)
declare function xbow:none ($sequence as item()*, $comparison-function as function(*)) as xs:boolean {
	fold-left(
		$sequence,
		true(),
		function ($result as xs:boolean, $next as item()) as xs:boolean {
			$result and not($comparison-function($next))
		}
	)
};

(:~ 
 : Returns true if at least one of the items in the given $sequence
 : return true for the $comparison-function
 :
 : Example
 :   <code>xbow:some((1,2,3), function ($i) { $i = 2 })</code>
 :
 : Returns
 :   <code>true()</code>
 :)
declare function xbow:some ($sequence as item()*, $comparison-function as function(*)) as xs:boolean {
	fold-left(
		$sequence,
		false(),
		function ($result as xs:boolean, $next as item()) as xs:boolean {
			$result or $comparison-function($next)
		}
	)
};

(: accessor helpers :)

declare function xbow:pluck ($field as xs:anyAtomicType) as item()* {
	xbow:pluck(?, $field)
};

declare function xbow:pluck ($map-or-array-or-node as item(), $field as xs:anyAtomicType) as item()* {
	typeswitch ($map-or-array-or-node)
		case array(*) return
			xbow:pluck-array($map-or-array-or-node, $field)
		case map(*) return
			xbow:pluck-map($map-or-array-or-node, $field)
		case node() return
			xbow:pluck-node($map-or-array-or-node, $field)

		default return
			error(xs:QName('xbow:invalid-argument'), ``[`{$map-or-array-or-node}` is not an array, a map nor a node]``)
};

declare function xbow:pluck-map ($field as xs:string) as item()* {
	xbow:pluck-map(?, $field)
};

declare function xbow:pluck-map ($map as map(*), $field as xs:string) as item()* {
	$map($field)
};

declare function xbow:pluck-array ($index as xs:integer) as item()* {
	xbow:pluck-array(?, $index)
};

declare function xbow:pluck-array ($array as array(*), $index as xs:integer) as item()* {
	$array($index)
};

declare function xbow:pluck-node ($field as xs:string) as item()* {
	xbow:pluck-node(?, $field)
};

declare function xbow:pluck-node ($node as node(), $field as xs:string+) as item()* {
	if (contains($field, '//')) then (
		error(xs:QName('xbow:invalid-dynamic-path'), ``[`{$field}` contains "//" which is not supported]``)
	) else if (contains($field, '/')) then (
		fold-left(tokenize($field, '/'), $node, xbow:pluck-node-part#2)
	) else if (count($field) > 1) then (
		fold-left($field, $node, xbow:pluck-node-part#2)
	) else (
		xbow:pluck-node-part($node, $field)
	)
};

declare %private function xbow:pluck-node-part ($node as node(), $path-part as xs:string?) as node()? {
	if (contains($path-part, ':') or contains($path-part, '[') or contains($path-part, '(')) then (
		error(xs:QName('xbow:invalid-dynamic-path'), ``[`{$path-part}` contains ":", "[" or "(" which is not supported]``)
	) else if (empty($path-part)) then (
		root($node)
	) else if ($path-part = ('', '.')) then (
		$node
	) else if ($path-part eq '..') then (
		$node/..
	) else if (starts-with($path-part, '@')) then (
		$node/@*[local-name() eq substring($path-part, 2)]
	) else (
		$node/*[name() eq $path-part]
	)
};

declare function xbow:pluck-deep ($fields as xs:anyAtomicType*) as item()* {
	xbow:pluck-deep(?, $fields)
};

declare function xbow:pluck-deep ($map-or-array-or-node as item(), $fields as xs:anyAtomicType*) as item()* {
	fold-left(
		$fields,
		$map-or-array-or-node,
		function ($eventual-item as item()*, $field) {
			if (exists($eventual-item)) then (
				xbow:pluck($eventual-item, $field)
			) else (
				)
		}
	)
};

(: stats :)

declare variable $xbow:disdup-init := map {'distinct': map {}, 'duplicates': ()};

declare function xbow:disdup-reducer ($result as map(*), $next as xs:string) as map(*) {
	if (exists($result?distinct($next))) then (
		map:put(
			$result,
			'duplicates',
			(
				$result?duplicates, $next
			)
		)
	) else (
		map:put($result, 'distinct', map:put($result?distinct, $next, true()))
	)
};

declare function xbow:distinct-duplicates ($s as item()*) as map(*) {
	fold-left($s, $xbow:disdup-init, xbow:disdup-reducer#2)
};

declare function xbow:distinct-duplicates ($s as item()*, $accessor as function(*)) as map(*) {
	fold-left(for-each($s, $accessor(?)), $xbow:disdup-init, xbow:disdup-reducer#2)
};

declare function xbow:sequence-stats-reducer ($result as map(*), $next as xs:numeric) as map(*) {
	map {
		'min': min(($result?min, $next)),
		'max': max(($result?max, $next)),
		'avg': ($result?sum + $next) div ($result?length + 1),
		'sum': $result?sum + $next,
		'length': $result?length + 1
	}
};

declare variable $xbow:initial-stats := map {'min': (), 'max': (), 'avg': 0.0, 'sum': 0, 'length': 0};

declare function xbow:num-stats ($sequence as xs:numeric*) as map(*) {
	fold-left($sequence, $xbow:initial-stats, xbow:sequence-stats-reducer#2)
};

(: conversion helper functions :)

declare function xbow:to-array ($sequence as item()*) as array(*) {
	array{
		$sequence
	}
};

declare function xbow:to-sequence ($array as array(*)) as item()* {
	$array?*
};

(: comparison helper functions :)

declare function xbow:ne ($comparison as item()) as function(*) {
	function ($i as item()) as xs:boolean {
		$i ne $comparison
	}
};

declare function xbow:ne ($comparison as item(), $accessor as function(*)) as function(*) {
	function ($i as item()) as xs:boolean {
		$accessor($i) ne $comparison
	}
};

declare function xbow:eq ($comparison as item()) as function(*) {
	function ($i as item()) as xs:boolean {
		$i eq $comparison
	}
};

declare function xbow:eq ($comparison as item(), $accessor as function(*)) as function(*) {
	function ($i as item()) as xs:boolean {
		$accessor($i) eq $comparison
	}
};

declare function xbow:gt ($comparison as item(), $accessor as function(*)) as function(*) {
	function ($i as item()) as xs:boolean {
		$accessor($i) gt $comparison
	}
};

declare function xbow:gt ($comparison as item()) as function(*) {
	function ($i as item()) as xs:boolean {
		$i > $comparison
	}
};

declare function xbow:ge ($comparison as item(), $accessor as function(*)) as function(*) {
	function ($i as item()) as xs:boolean {
		$accessor($i) >= $comparison
	}
};

declare function xbow:ge ($comparison as item()) as function(*) {
	function ($i as item()) as xs:boolean {
		$i >= $comparison
	}
};

declare function xbow:lt ($comparison as item(), $accessor as function(*)) as function(*) {
	function ($i as item()) as xs:boolean {
		$accessor($i) lt $comparison
	}
};

declare function xbow:lt ($comparison as item()) as function(*) {
	function ($i as item()) as xs:boolean {
		$i lt $comparison
	}
};

declare function xbow:le ($comparison as item(), $accessor as function(*)) as function(*) {
	function ($i as item()) as xs:boolean {
		$accessor($i) le $comparison
	}
};

declare function xbow:le ($comparison as item()) as function(*) {
	function ($i as item()) as xs:boolean {
		$i le $comparison
	}
};

(: control-flow helpers :)

declare function xbow:test ($item as item()*, $test as function(*), $then as function(*)) as item()* {
	if ($test($item)) then (
		$then($item)
	) else (
		$item
	)
};

declare function xbow:if (
	$item as item()*,
	$test as function(*),
	$then as function(*),
	$else as function(*)
) as item()* {
	if ($test($item)) then (
		$then($item)
	) else (
		$else($item)
	)
};

declare function xbow:and ($item as item()*, $a as function(*), $b as function(*)) as item()* {
	if ($a($item) and $b($item)) then (
		$item
	) else (
		)
};

declare function xbow:or ($item as item()*, $a as function(*), $b as function(*)) as item()* {
	if ($a($item) or $b($item)) then (
		$item
	) else (
		)
};

declare function xbow:xor ($item as item()*, $a as function(*), $b as function(*)) as item()* {
	let $_a := $a($item)
	let $_b := $b($item)
	return if (($_a or $_b) and not($_a and $_b)) then (
			$item
		) else (
			)
};

declare function xbow:nor ($item as item()*, $a as function(*), $b as function(*)) as item()* {
	if (not($a($item)) and not($b($item))) then (
		$item
	) else (
		)
};

(: node constructors
 : these functions are inspired by a new standard proposed by Michael Kay
 :)

declare function xbow:attribute ($name as item()*) as function (xs:string) as attribute() {
	typeswitch ($name)
		case xs:QName return
			xbow:attribute-ns($name, ?)
		case xs:string return
			xbow:attribute($name, ?)

		default return
			error(
				xs:QName('xbow:invalid-argument'),
				'Invalid type of $name in xbow:element#1, expected either xs:QName or xs:string'
			)
};

declare function xbow:attribute-ns ($name as xs:QName, $contents as item()*, $joiner as xs:string) as attribute() {
	attribute {$name} {
		string-join($contents, $joiner)
	}
};

declare function xbow:attribute ($name as xs:string, $contents as item()*, $joiner as xs:string) as attribute() {
	attribute {$name} {
		string-join($contents, $joiner)
	}
};

declare function xbow:attribute-ns ($name as xs:QName, $value as xs:string) as attribute() {
	attribute {$name} {
		$value
	}
};

declare function xbow:attribute ($name as xs:string, $value as xs:string) as attribute() {
	attribute {$name} {
		$value
	}
};

declare function xbow:element ($name as item()) as function (item()*) as element() {
	typeswitch ($name)
		case xs:QName return
			xbow:element-ns($name, ?)
		case xs:string return
			xbow:element($name, ?)

		default return
			error(
				xs:QName('xbow:invalid-argument'),
				'Invalid type of $name in xbow:element#1, expected either xs:QName or xs:string got: ' || xbow:get-type($name)
			)
};

declare function xbow:element ($name as xs:string, $contents as item()*) as element() {
	element {$name} {
		$contents
	}
};

declare function xbow:element-ns ($name as xs:QName, $contents as item()*) as element() {
	element {$name} {
		$contents
	}
};

(: wrapping values in nodes :)

(:~
 : wrap item(s) in node with name $node-name
 : returns function that returns an element()
 : <$node-name>$item(s)</$node-name>
 :)
declare function xbow:wrap-element ($contents as item()*, $name as item()) as element() {
	typeswitch ($name)
		case xs:QName return
			xbow:element-ns($name, $contents)
		case xs:string return
			xbow:element($name, $contents)

		default return
			error(
				xs:QName('xbow:invalid-argument'),
				'Invalid type of $name in xbow:wrap-element#2, expected either xs:QName or xs:string for parameter two got: ' ||
					xbow:get-type($name)
			)
};

declare function xbow:wrap-attribute ($value as item()*, $attribute-name as xs:string) as attribute() {
	xbow:attribute($attribute-name, string-join($value, ' '))
};

(:~
 : wrap item(s) in attribute with name $attribute-name
 : returns function that returns an attribute()
 : multiple items will be joined into a single string separated by $joiner
 :)
declare function xbow:wrap-attribute ($value as item()*, $name as xs:string, $joiner as xs:string) as attribute() {
	xbow:attribute($name, string-join($value, $joiner))
};

(:~
 : wrap each item(s) in node with name $node-name
 : returns function that returns a sequence of elements
 : Example:
(
   <$node-name>$item[1]</$node-name>,
   <$node-name>$item[1]</$node-name>,
   <$node-name>$item[1]</$node-name>
)
 :)
declare function xbow:wrap-each ($values as item()*, $node-name as xs:string) as element()* {
	for-each($values, xbow:element($node-name, ?))
};

declare function xbow:wrap-map-attribute ($map as map(*)) as attribute()* {
	map:for-each($map, xbow:attribute#2)
};

declare function xbow:wrap-map-element ($map as map(*)) as element()* {
	map:for-each($map, xbow:element#2)
};

declare function xbow:map-filter-keys ($map as map(*), $keys as xs:string*) as map(*) {
	for-each(
		$keys,
		function ($key as xs:anyAtomicType) {
			map:entry($key, $map($key))
		}
	)
		=> map:merge()
};

(:~
 : flip keys and values of a map 
 : Example:
    xbow:map-reverse(map { 'key': 'value'})
 :)
declare function xbow:map-flip ($map as map(*)) as map(*) {
	map:for-each(
		$map,
		function ($key as xs:anyAtomicType, $value as xs:anyAtomicType) as map(*) {
			map {$value: $key}
		}
	)
		=> map:merge()
};

(:~ 
 : reverse map with non-atomic values
 : because `xbow:map-reverse(map { 'key': (1 to 10)})` would throw

 : Example:
    xbow:map-reverse(map { 'key': (1 to 10)}, sum#1)

 : reverse map but do something with the value too

 : Example:
    xbow:map-reverse(map { 'key': 'value'}, function ($v) { upper-case($v) }),
    xbow:map-reverse(map { 'key': 'value'}, function ($v) { util:uuid($v) })
 :)
declare function xbow:map-flip ($map as map(*), $hash-value as function(*)) as map(*) {
	map:for-each(
		$map,
		function ($key as xs:anyAtomicType, $value as item()*) as map(*) {
			map {$hash-value($value): $key}
		}
	)
		=> map:merge()
};

(:~
 : Get type information of $item
 : will attempt to determine deep structure specific types
 : 
 : Example:
   xbow:get-type([map{"a": true(), "b": false()}, map{"a":false()}]) 
 : returns "array(map(xs:string, xs:boolean))"
 :)
declare function xbow:get-type ($item as item()?) as xs:string {
	typeswitch ($item)
		case element() return
			``[element(`{name($item)}`)]``
		case attribute() return
			``[attribute(`{name($item)}`)]``
		case text() return
			'text()'
		case comment() return
			'comment()'
		case array(*) return
			``[array(`{xbow:array-type($item)}`)]``
		case map(*) return
			``[map(`{xbow:map-type($item)}`)]``
		(: XQuery 3.1 does not specify inspection functions only arity can be read :)
		case function(*) return
			'function(*)'
		case xs:boolean return
			'xs:boolean'
		case xs:string return
			'xs:string'
		case xs:positiveInteger return
			'xs:positiveInteger'
		case xs:negativeInteger return
			'xs:negativeInteger'
		case xs:integer return
			'xs:integer'
		case xs:double return
			'xs:double'
		case xs:float return
			'xs:float'
		case xs:decimal return
			'xs:decimal'
		case xs:date return
			'xs:date'
		case xs:time return
			'xs:time'
		case xs:dateTime return
			'xs:dateTime'
		case xs:QName return
			'xs:QName'
		case xs:NCName return
			'xs:NCName'
		case xs:anyAtomicType return
			'xs:anyAtomicType'

		default return
			'item()'
};

declare function xbow:array-type ($array as array(*)) as xs:string {
	if (array:size($array) eq 0) then
		'*'
	else
		array:fold-left($array, (), xbow:subtype-reducer#2)
};

declare function xbow:map-type ($map as map(*)) as xs:string {
	let $keys := map:keys($map)
	return if (count($keys) eq 0) then
			'*'
		else
			fold-left(
				$keys,
				[(), ()],
				function ($result as array(xs:string), $next as xs:anyAtomicType) {
					[xbow:subtype-reducer($result?1, $next), xbow:subtype-reducer($result?2, $map($next))]
				}
			)
				=> (
					function ($array as array(xs:string)) as xs:string {
						if ($array?1 = '*' and $array?2 = '*') then
							'*'
						else
							string-join($array?*, ', ')
					}
				)()
};

declare %private function xbow:subtype-reducer ($result as xs:string?, $item as item()?) as xs:string {
	if ($result = '*') then
		$result (: fast-track mixed content :)
	else if (not(exists($item))) then
		'*'
	else if (not(exists($result))) then
		xbow:get-type($item)
	else if (xbow:get-type($item) eq $result) then
		$result
	else
		'*'
};

declare function xbow:instance-of ($item as item()?, $type as xs:string) as xs:boolean {
	(: complex types :)

	if (starts-with($type, 'array')) then
		$item instance of array(*)
	else if (starts-with($type, 'map')) then
		$item instance of map(*)
	else if (starts-with($type, 'function')) then
		$item instance of function(*)
	else if (starts-with($type, 'node')) then
		$item instance of node()
	else if (starts-with($type, 'element')) then
		$item instance of element()
	else if (starts-with($type, 'attribute')) then
		$item instance of attribute()
	else if (starts-with($type, 'text')) then
		$item instance of text()
	else if (starts-with($type, 'document')) then
		$item instance of document-node()
	(: simple types :)

	else if (ends-with($type, 'anyAtomicType')) then
		$item instance of xs:anyAtomicType
	else if (ends-with($type, 'string')) then
		$item instance of xs:string
	else if (ends-with($type, 'numeric')) then
		$item instance of xs:numeric
	else if (ends-with($type, 'decimal')) then
		$item instance of xs:decimal
	else if (ends-with($type, 'integer')) then
		$item instance of xs:integer
	else if (ends-with($type, 'dateTime')) then
		$item instance of xs:dateTime
	else if (ends-with($type, 'date')) then
		$item instance of xs:date
	else if (ends-with($type, 'time')) then
		$item instance of xs:time
	else if (ends-with($type, 'boolean')) then
		$item instance of xs:boolean
	(: generic types :)

	else if (starts-with($type, 'item')) then
		$item instance of item()
	else if (starts-with($type, 'empty-sequence')) then
		$item instance of empty-sequence()
	(: unknown types :)

	else
		error(xs:QName('xbow:unknown-type'), "Unknown or unsupported type:'" || $type || "'.")
};

(:~
 : flip the order of arguments of a function with exactly two
 : parameters
 : @param function(*) $f two argument function 
 : @returns calls function $f with its arguments flipped
 :)
declare function xbow:flip-arguments (
	$a as item()*,
	$b as item()*,
	$f as function (item()*, item()*) as item()*
) as function(*) {
	if (function-arity($f) ne 2) then (
		error(
			xs:QName('xbow:wrong-number-of-arguments'),
			``[Received a function with an arity of `{function-arity($f)}` to xbow:flip-arguments but must be exactly 2]``
		)
	) else (
		$f($b, $a)
	)
};

declare function xbow:apply-insert-at (
	$argument as item()*,
	$function as function(*),
	$position as xs:integer,
	$other-arguments as array(*)
) as item()* {
	apply($function, array:put($other-arguments, $position, $argument))
};

declare function xbow:apply-as-last (
	$argument as item()*,
	$function as function(*),
	$other-arguments as array(*)
) as item()* {
	apply($function, array:append($other-arguments, $argument))
};

(:~
 : combine a sequence of $functions and returns the combined function
 :)
declare function xbow:combine ($functions as function(*)*) as function(*) {
	function ($initial as item()*) {
		fold-left($functions, $initial, xbow:combination-reducer#2)
	}
};

declare %private function xbow:combination-reducer ($result as item()*, $next as function(*)) as item()* {
	apply($next, xbow:spread($result, function-arity($next)))
};

declare %private function xbow:spread ($arguments as item()*, $arity as xs:integer) as array(*) {
	if (count($arguments) < $arity) then
		error(
			xs:QName('xbow:not-enough-arguments'),
			``[Received `{count($arguments)}` argument(s) for a function with arity `{$arity}`]``
		)
	else if ($arity = 1) then
		[$arguments]
	else
		array:join(([head($arguments)], xbow:spread(tail($arguments), $arity - 1)))
};

(:~
 : categorize all elements of $sequence by first matching rule in $rules
 :)
declare function xbow:categorize ($sequence as item()*, $rules as array(function(*))) as function(*) {
	let $test := xbow:find-first-matching($rules, ?)
	let $zero := xbow:array-fill(array:size($rules), ())
	return fold-left(
			$sequence,
			$zero,
			function ($result as array(*), $item as item()) {
				let $pos := $test($item)
				return if ($pos eq 0) then (
						$result
					) (: $item did not match any criteria :) else (
						xbow:array-put(
							$result,
							$pos,
							(
								$result($pos), $item
							)
						)
					)
			}
		)
};

(:~
 : spread all elements of $sequence over $scale using an $accessor function
 :)
declare function xbow:categorize (
	$sequence as item()*,
	$rules as array(function(*)),
	$accessor as function(*)
) as array(*) {
	let $test := xbow:find-first-matching($rules, ?)
	let $zero := xbow:array-fill(array:size($rules), ())
	return fold-left(
			$sequence,
			$zero,
			function ($result as array(*), $item as item()) {
				let $pos := $test($accessor($item))
				return if ($pos eq 0) then (
						$result
					) (: $item did not match any criteria :) else (
						xbow:array-put(
							$result,
							$pos,
							(
								$result($pos), $item
							)
						)
					)
			}
		)
};

(:~
 : xquery implemention of a special array:put in xquery
 : fills elements of sparse arrays with empty sequences
 :)
declare function xbow:array-put ($array as array(*), $pos as xs:integer, $items-to-put as item()*) as array(*) {
	array:join(
		if (array:size($array) < $pos) then (
			$array,
				xbow:array-fill(
					$pos - array:size($array) - 1,
					(
						)
				),
				[$items-to-put]
		) else if (array:size($array) > $pos + 1) then (
			array:subarray($array, 1, $pos - 1), [$items-to-put], array:subarray($array, $pos + 1)
		) else (
			array:subarray($array, 1, $pos - 1), [$items-to-put], array:subarray($array, $pos + 1)
		)
	)
};

(:~
 : Return the last item in a sequence or array.
 : Will return an empty sequence if array or sequence is empty
 :)
declare function xbow:last ($array-or-sequence as item()*) as item()? {
	typeswitch ($array-or-sequence)
		case array(*) return
			xbow:last-member-of($array-or-sequence)

		default return
			xbow:last-item-of($array-or-sequence)
};

(:~
 : Return the last item in a sequence.
 : Will return an empty sequence if sequence is empty
 :)
declare function xbow:last-item-of ($seq as item()*) as item()? {
	if (count($seq)) then (
		$seq[count($seq)]
	) else (
		)
};

(:~
 : Return the last item in array.
 : Will return an empty sequence if array is empty
 :)
declare function xbow:last-member-of ($array as array(*)) as item()? {
	if (array:size($array)) then (
		$array(array:size($array))
	) else (
		)
};

(:~
 : Extended for-each, will pass the position of the current item
 : to the provided function.
 : Functional equivalent of `for $item at $pos in $seq`.

 Example:
    xbow:sequence-for-each-index((1,2,3), function ($i, $p) { $i + $p })
 :)
declare function xbow:sequence-for-each-index ($seq as item()*, $func as function(*)) as item()* {
	fold-left(
		$seq,
		[0, ()],
		function ($result as array(*), $next as item()) {
			let $pos := $result?1 + 1
			return [$pos, ($result?2, $func($next, $pos))]
		}
	)?2
};

(:~
 : Extended array:for-each, will pass the position of the current item
 : to the provided function.

 Example:
    xbow:array-for-each-index([1,2,3], function ($i, $p) { $i + $p })
 :)
declare function xbow:array-for-each-index ($arr as array(*), $func as function(*)) as array(*) {
	array:fold-left(
		$arr,
		[0, []],
		function ($result as array(*), $next as item()*) {
			let $next-pos := $result?1 + 1
			return [$next-pos, array:append($result?2, $func($next, $next-pos))]
		}
	)?2
};

(:~
 : Universal, extended for-each, will pass the position of the current item
 : to the provided function and can work with sequences and arrays.

 Example:
    xbow:for-each-index((1,2,3), function ($i, $p) { $i + $p })
    xbow:for-each-index([1,2,3], function ($i, $p) { $i + $p })
 :)
declare function xbow:for-each-index ($array-or-items as item()*, $func as function(*)) as item()* {
	typeswitch ($array-or-items)
		case array(*) return
			xbow:array-for-each-index($array-or-items, $func)

		default return
			xbow:sequence-for-each-index($array-or-items, $func)
};

(:~
 : returns an array of size $size
 : the items can be set to (), a single value or be returned by a 
 : function provided as the second value

 Examples:
   xbow:array-fill(4, ()),
   xbow:array-fill(4, function ($i, $p) { $i + $p })
 :)
declare function xbow:array-fill ($size as xs:integer, $function-or-value as item()?) as array(*) {
	if ($size < 1) then (
		error(xs:QName('xbow:invalid-argument'), 'array size must be greater than zero')
	) else (
		typeswitch ($function-or-value)
			case function(*) return
				xbow:array-for-each-index(
					array{
						(
							1 to $size
						)
					},
					$function-or-value
				)

			default return (: we need an array to iterate over for [(),()] to be possible :)
				array:for-each(
					array{
						(
							1 to $size
						)
					},
					function ($ignore) {
						$function-or-value
					}
				)
	)
};

declare %private function xbow:match-first (
	$item as item(),
	$result as xs:integer+,
	$rule as function(*)
) as xs:integer+ {
	let $current-pos := head($result) + 1
	let $current-match := tail($result)
	return if ($current-match > 0) then
			$result (: did match, do nothing :)
		else if ($rule($item)) then (
			$current-pos, $current-pos
		) else (
			$current-pos, $current-match
		)
};

declare %private function xbow:match-all (
	$item as item(),
	$result as xs:integer+,
	$rule as function(*)
) as xs:integer+ {
	let $current-pos := head($result) + 1
	let $current-match := tail($result)
	return if ($rule($item)) then (
			$current-pos, $current-pos
		) else (
			$current-pos, $current-match
		)
};

declare %private function xbow:find-first-matching ($rules as array(*), $item as item()) as xs:integer {
	array:fold-left($rules, (0, 0), xbow:match-first($item, ?, ?)) => tail()
};

(:~
 : transform an $array of items into an array of maps
 : with two keys each:
 : 'items' (n-th item of the first array) and
 : 'label' (n-th item of the second array)
 : NOTE: both arrays must have the same size
 :)
declare function xbow:label ($array as array(*), $labels as array(*)) as array(map(*)) {
	array:for-each-pair($array, $labels, xbow:assign-label#2)
};

declare %private function xbow:assign-label ($items as item()*, $label as xs:string) as map(xs:string, item()*) {
	map {'items': $items, 'label': $label}
};



