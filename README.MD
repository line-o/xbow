
# xBow

Xquery helper function library to be used with the arrow operator.
Should be read as **crossbow**, a tool to shoot arrows fast and accurately.

## Usage

The library provides a small number of useful functions when working with the
arrow operator with sequences or sequences in general.

## Filtering

```xquery
(0 to 9) => filter(xbow:gt(4)) => filter(xbow:lt(6))
```

The above code outputs 5 since all numbers less and greater were filtered out.

## Grouping

Shamelessly copied from D3 `xbow:groupBy` expects a key function as its second
parameter.

```xquery
(
  <user first='Mike' last='H'/>,
  <user first='Paula' last='M'/>,
  <user first='Carla' last='H'/>,
  <user first='Fela' last='M'/>
)
  => xbow:groupBy(function ($item) { $item/@last/string() })
```

Since the key function (or accessor) knows how to deal with the datatype of your
sequence `xbow:groupBy` can be used to group nodes, maps and arrays or other items.

## Sorting

This is just a small wrapper around the normal sort function.

```xquery
(0, 3, 9, 8) => xbow:sortBy(function ($a) { -$a })
```

This will sort numerical entries in ascending order.

For more examples you can also look at the tests.

## arrow syntax

works

```xquery
  (0 to 9) => sum(),
  (0 to 9) => sum(?)
```

throws

```xquery
  (0 to 9) => sum(.)
```

## known issues

wrapping nodes in existdb v4.2.1 and above 
