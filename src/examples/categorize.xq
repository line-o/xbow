xquery version "3.1";


import module namespace xbow = 'http://line-o.de/xq/xbow';

let $age-rules := [
    xbow:lt(10),
    xbow:lt(20),
    xbow:lt(30),
    xbow:lt(60),
    xbow:ge(60)
]

let $age-labels := [
    'minors',
    'youngsters',
    'twens',
    'adults',
    'seniors'
]

let $age-accessor := function ($i as map(*)) { $i?age }

let $activity-rules := [
    xbow:lt(5),
    xbow:lt(20),
    xbow:ge(20)
]

let $activity-labels := [
    'inactive',
    'active',
    'hyperactive'
]

let $post-accessor := function ($i as element(person)) { xs:integer($i/@posts) }

return (
    xbow:categorize((1, 3, 4, 5, 6, 7, 8, 9, 9, 0, 34, 45, 65), $age-rules),
    xbow:categorize((1, 3, 4, 5, 6, 7, 8, 9, 9, 0, 34, 45, 65), $activity-rules),
    (1, 3, 4, 5, 6, 7, 8, 9, 9, 0, 34, 45, 65) 
        => xbow:categorize($age-rules)
        => xbow:label($age-labels)
    ,
    (
        map { "age": 1, "name": "a" },
        map { "age": 3, "name": "b" },
        map { "age": 4, "name": "c" },
        map { "age": 5, "name": "d" },
        map { "age": 6, "name": "e" },
        map { "age": 7, "name": "f" },
        map { "age": 8, "name": "g" },
        map { "age": 9, "name": "h" },
        map { "age": 9, "name": "i" },
        map { "age": 17, "name": "j" },
        map { "age": 34, "name": "k" },
        map { "age": 45, "name": "l" },
        map { "age": 54, "name": "m" }
    )
        => xbow:categorize($age-rules, $age-accessor)
        => xbow:label($age-labels)
    ,
    (
        <person posts="1" name="a" />,
        <person posts="3" name="b" />,
        <person posts="4" name="c" />,
        <person posts="5" name="d" />,
        <person posts="6" name="e" />,
        <person posts="7" name="f" />,
        <person posts="8" name="g" />,
        <person posts="9" name="h" />,
        <person posts="9" name="i" />,
        <person posts="17" name="j" />,
        <person posts="34" name="k" />,
        <person posts="45" name="l" />,
        <person posts="54" name="m" />
    )
        => xbow:categorize($activity-rules, $post-accessor)
        => xbow:label($activity-labels)
)
