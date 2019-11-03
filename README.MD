
# xBow

Xquery helper function library to be used with the arrow operator.
Should be read as **crossbow**, a tool to shoot arrows fast and accurately.

## Usage

The library provides a small number of useful functions when working with the
arrow operator with sequences or sequences in general.

Install the [XAR](https://github.com/line-o/xbow/releases/) and

    import module namespace xbow="http://line-o.de/xq/xbow";

Below you'll find some key things xbow has to offer, for more examples you can 
also look at the [tests](https://github.com/line-o/xbow/tree/master/test).

## Filtering

```xquery
(0 to 9) => filter(xbow:gt(4)) => filter(xbow:lt(6))
```

The above code outputs 5 since all numbers less and greater were filtered out.

## Grouping

Grouping items after an arrow would require some boilerplate code.
This is where `xbow:groupBy` comes in handy.

```xquery
(
  <user first='Mike' last='H'/>,
  <user first='Paula' last='M'/>,
  <user first='Carla' last='H'/>,
  <user first='Fela' last='M'/>
)
  => xbow:groupBy(function ($item) { $item/@last/string() })
```

The second parameter is an accessor function. A concept shamelessly copied from [D3](https://d3js.org).

Since the key function (or accessor) knows how to deal with the datatype of your
sequence items, `xbow:groupBy` can be used to group nodes, maps and arrays. 
All `item()*` welcome.

The function will always return a map. It will have all items of the input sequence.
The keys are all return values produced by the accessor function.

```xquery
map {
  'H': (
    <user first='Mike' last='H'/>,
    <user first='Carla' last='H'/>
  )
  'M': (
    <user first='Paula' last='M'/>,
    <user first='Fela' last='M'/>
  )
}
```

## Sorting

This is just a small wrapper around the normal sort function.
Mainly, to not have to remember to add an empty sequence,
if you just want to use a sorting function.

This will sort numerical entries in ascending order.

```xquery
(0, 3, 9, 8) => xbow:sortBy(function ($a) { -$a })
```

Returns `(9, 8, 3, 0)`


Using `fn:sort` produces the same output.

```xquery
(0, 3, 9, 8) => sort((), function ($a) { -$a })
```


## General Arrow Syntax

Remember:

```xquery
  (0 to 9) => sum(),
  (0 to 9) => sum(?)
  (0 to 9) => (function($a) { sum($a) })()
```
is fine

but `(0 to 9) => sum(.)`
or `(0 to 9) => sum#1`
or `(0 to 9) => function ($a) { sum($a) }`
all **throw**!

## Known Issues

Prior to version 4.7.0 existdb would hand over a context object to 
`for-each` and `filter`. 
This leads to unpredictable behaviour when using `xbow:wrap` and others.
