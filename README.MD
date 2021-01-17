# xBow

![xBow logo](src/readme.svg)

![Test and Release](https://github.com/line-o/xbow/workflows/Test%20and%20Release/badge.svg) [![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

XQuery helper function library to be used with the arrow operator.
Should be read as **crossbow**, a tool to shoot arrows fast and accurately.

## Usage

The library provides a small number of useful functions when working with the
arrow operator with sequences or sequences in general.

Install the [XAR](https://github.com/line-o/xbow/releases/) and

    import module namespace xbow="http://line-o.de/xq/xbow";

Below you'll find some key things xbow has to offer.
For more, have a look at the
[examples](https://github.com/line-o/xbow/tree/master/src/examples) and
[tests](https://github.com/line-o/xbow/tree/master/src/test).

Even if the module was developed with arrow expressions in mind,
all of it can be used without this language feature, as well.

## Requirements

- XQuery version 3.1+
- eXist-db version 4.7.0+

## Accessors

Many of the functions in this module have a second signature, expecting an accessor function.
This concept was inspired by [D3](https://d3js.org), since it is an excellent tool to mangle data.

The idea is that you tell the operation you want to perform how to retrieve the value it should 
operate on. 
Maybe you want to filter user elements by let's sey their karma points property, but you do not want to lose
the elements itself in the process. Then, passing an accessor to the comparison function would
do the trick.
Since the key function (or accessor) knows how to deal with the datatype of your
sequence items, most operations can be used on atomics, nodes, maps and arrays. 
All `item()*` welcome.

In the section [Grouping](#Grouping) is a code example.

There are two functions, `xbow:pluck` and `xbow:pluck-deep`, that can help making use of accessors.
The second example in [Filtering](#Filtering) uses pluck.

## Filtering

```xquery
(0 to 9) => filter(xbow:gt(4)) => filter(xbow:lt(6))
```

The above code outputs 5 since all numbers less and greater were filtered out.

`xbow` implements the usual comparison functions `eq`, `ne`, `lt`, `le`, `gt` and `ge`.

They all return a function, so that they can be used in combination with filter and
for-each. They all accept an [accessor](#Accessors) as a second argument.

Here it is in action (this time using an array as input):

```xquery
[
  map { 'a': 1, 'b': 2 },
  map { 'a': 2, 'b': 1 },
  map { 'a': 3, 'b': 1 }
] 
    => array:filter(xbow:eq(1, xbow:pluck('b')))
    => array:for-each(xbow:pluck('a'))
    (: yields (2, 3) :)
```

## Grouping

Grouping items after an arrow would require some boilerplate code.
This is where `xbow:groupBy` comes in handy.

```xquery
(
  <user first='Mike' last='Hill'/>,
  <user first='Paula' last='Moon'/>,
  <user first='Carla' last='Harlowe'/>,
  <user first='Fela' last='Kuti'/>
)
  => xbow:groupBy(function ($item as element()) {
      substring($item/@last, 1, 1) })
```

The second parameter is an accessor function. A concept shamelessly copied from [D3](https://d3js.org).


The function will always return a map. It will have all items of the input sequence.
Any value produced by the accessor function, will be a key in the resulting map.

```xquery
map {
  'H': (
    <user first='Mike' last='Hill'/>,
    <user first='Carla' last='Harlowe'/>
  )
  'M': <user first='Paula' last='Moon'/>,
  'K': <user first='Fela' last='Kuti'/>
}
```

## Sorting

This is just a small wrapper around the normal sort function.
Mainly, to not have to remember to add an empty sequence,
if you just want to use a sorting function.

This will sort numerical entries in descending order.

```xquery
(0, 3, 9, 8) => xbow:descending()
```

Returns `(9, 8, 3, 0)`


Using `fn:sort` produces the same output.

```xquery
(0, 3, 9, 8) => sort((), function ($a) { -$a })
```

## Folding

`fold-left`, `fold-right`

Sometimes you want to test a sequence of items if all, some or
none of them meet a certain condition.

### All

`xbow:all` returns true, if the testing function returns `true()` for _each item_.

```xquery
(1 to 4) => xbow:all(xbow:lt(5))
```

### Some

`xbow:some` returns true, if the testing function returns `true()` for _at least one item_.

```xquery
('1', '2', '3') => xbow:some(xbow:eq('2'))
```

### None

`xbow:none` returns true, if the testing function returns `false()` for _each item_.

```xquery
(['1', '1'], ['1', '2'], ['1', '3']) => xbow:none(xbow:eq('2', xbow:pluck(1)))
```

## Nodes

There is a number of functions to output or operate on nodes, attributes and elements.

For example:
Wrapping a single value in an element of a certain type with `wrap-element` or
each item in a sequence (`wrap-each`).

```xquery
(1 to 3) 
  => xbow:wrap-each('item')
  => xbow:wrap-element('root')
```

outputs

```xml
<root>
  <item>1</item>
  <item>2</item>
  <item>3</item>
</root>
```

## Utility

Some handy expressions in XQuery, like `?*` to convert an array
into a sequence, cannot be easily used after the arrow operator.
xbow wraps those in functions for you so that you do not have to.

```xquery
[1,2] => xbow:to-sequence(),
(1,2) => xbow:to-array()
```

FLWOR operations allow you to operate on the position of each element.
`fn:for-each` does not allow that.
`xbow:for-each-index` adds that. You can operate on a sequence or an array 

```xquery
(2 to 4)
  => xbow:for-each-index(function ($v, $i) {
    if ($i = 2) then ($v - $i) else ($v)
  })
```

results in `(2, 1, 4)`. Only the value for the second item changed.


`xbow:array-fill` lets you create an arrayfill an array with a value

```xquery
xbow:array-fill(3, true())
```

or the return value of a function

```xquery
xbow:array-fill(10, function ($value, $position) {
  xbow:lt(($value - 5))
})
```

The above will output an array of 10 anonymous functions.
Each of them comparators suitable to use in `xbow:categorize`.
The range will be from `xbow:lt(-5)` to `xbow:lt(5)`.

`xbow:last` is the latest addition to the utility functions.
It returns the last element of a sequence or array. If the list
does not contain elements an empty sequence is returned.

```xquery
[1, 2, 9] => xbow:last() (: returns 9 :)
```

```xquery
(1, 2, 9) => xbow:last() (: returns 9 :)
```

```xquery
(1, 2, []) => xbow:last() (: returns [] :)
```

## General Arrow Syntax

**Remember:**

```xquery
  (0 to 9) => sum(),
  (0 to 9) => (function($a) { sum($a) })()
```
is **fine**.

```xquery
  (0 to 9) => concat(?)
```
will return **a function** with an arity of 1.

**But**

`(0 to 9) => sum(.)`,

`(0 to 9) => sum#1` or

`(0 to 9) => function ($a) { sum($a) }`

will throw an **exception**!

## Roadmap / TODOs

- [x] Add convenience functions for boolean tests on sequence items (`all`, `none`, `some`) 
- [x] Rename xbow:map-reverse (to xbow:map-flip for example)
- [ ] Change namespace to `xb` for brevity
- [ ] Test/support elements with namespaces in `wrap*`

- [ ] More examples
- [ ] Extend documentation on concepts
- [ ] Generate XQDoc documentation at build

- [x] Replace `ant` with `gulp-exist` +watcher 
- [ ] Create packages for other XQuery runtimes

## Compatibility

The xBow module tests are written for [eXist-db](https://exist-db.org) and this is also its build target.
In theory the core library module should run on any XQuery 3.1 processor.
It depends on functions only available in XQuery version 3.1 (or higher).

The xBow module is compatible with Saxon 10 (HE) since v1.2.0. Older versions of the Home Edition of Saxon
do not allow the use of higher order functions. Saxon 9 PE and 9 EE might work as well. 

You can run xBow on baseX (tested with version 9.4.5). To install the most recent version run
`REPO INSTALL https://raw.githubusercontent.com/line-o/xbow/master/src/content/xbow.xqm`
in basex REPL.

The released package requires eXist-db 4.7.0 or higher, due to a bug that caused
unpredictable behaviour when using `xbow:wrap-element` and related functions (see [original issue](https://github.com/eXist-db/exist/issues/1960) for details).

## Performance

We are trading readability, maintainability and comfort for speed with this module.
FLOWR-expressions are well optimized and execute at least twice as fast.
This module will only really shine when the runtime is able to parallelize function calls and would
also benefit heavily from lazy evaluation.

