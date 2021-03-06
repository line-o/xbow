xquery version "3.1";

import module namespace xbow="http://line-o.de/xq/xbow";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "no";

declare variable $local:xml :=
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

declare variable $local:age-category-rules := [
    xbow:lt(12), xbow:lt(20), xbow:lt(30), xbow:lt(60),
    xbow:lt(120), xbow:ge(120)
];

declare function local:user-age ($item as node()) as xs:integer {
    xs:integer($item/@age)
};

declare function local:first-letter-of-last-name ($item) {
    substring($item/@last, 1, 1)
};

declare function local:serialize-users ($users as element(user)*) {
    if (empty($users))
    then ("none")
    else (for-each($users, function ($user) {
        ``[`{$user/@last}`, `{$user/@first}`: `{$user/@age}`]``
    }))
};

declare function local:identity ($i) { $i };

declare function local:render-stats ($map, $seq) {
    for-each($seq, function ($key) {
        xbow:wrap-element($key, 'dt'),
        $map($key) => xbow:wrap-each('dd')
    })
};

declare function local:render-user-age-category ($cat) {
    xbow:wrap-element($cat?label, 'dt'),
    if (empty($cat?items))
    then (<dd>none</dd>)
    else (
        $cat?items
            => for-each(function ($user) {
                ``[`{$user/@last}`, `{$user/@first}`: `{$user/@age}`]`` })
            => xbow:wrap-each('dd')
    )
};


element html {
    element body {
        element h1 { 'User Stats' },
        element p {
            "useless stat of the day: ",
            (: how many users last name begins with letter 'H'? :)
            $local:xml//user
                => xbow:groupBy(local:first-letter-of-last-name#1)
                => xbow:pluck('H')
                => count()
                => concat(" user's lastnames start with the letter H")
                => xbow:wrap-element('strong')
        },
        element h2 { "By Age Category" },
        (: group users by age :)
        $local:xml//user
            => xbow:categorize($local:age-category-rules, local:user-age#1)
            => xbow:label([
                'children', 'teens', 'twens', 'adults', 'seniors', 'miracle' ])
            => array:for-each(local:render-user-age-category#1)
            => xbow:wrap-element('dl')
        ,
        element h2 { "Age Stats" },
        (: minimum, maximum and average age :)
        $local:xml//user
            => for-each(local:user-age#1)
            => xbow:num-stats()
            => local:render-stats(('min', 'max', 'avg'))
            => xbow:wrap-element('dl')
    }
}
