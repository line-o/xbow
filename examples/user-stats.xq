xquery version "3.1";

import module namespace xbow="http://line-o.de/xq/xbow";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
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

declare function local:first-letter-of-last ($item) {
    substring($item/@last, 1, 1)
};

declare function local:age-group ($item) {
    let $num-age := xs:integer($item/@age)
    return
        if ($num-age < 12)
        then ('children')
        else if ($num-age < 20)
        then ('teens')
        else if ($num-age < 30)
        then ('twens')
        else if ($num-age < 60)
        then ('adults')
        else if ($num-age < 120)
        then ('seniors')
        else ('miracle')
};

declare function local:serialize-users ($users as element(user)*) {
    for-each($users, function ($user) {
        ``[`{$user/@last}`, `{$user/@first}`: `{$user/@age}`]``
    })
};

declare function local:identity ($i) { $i };

declare function local:serialize-map-sorted-a ($map, $seq) {
    let $f := function ($key) {
        xbow:wrap-element($key, 'dt'),
        $map($key)
(:            => local:identity():)
            => xbow:wrap-each('dd')
    }

    return $seq
        => for-each($f)
};

declare function local:serialize-map-sorted-b ($map, $seq) {
    let $f := function ($key) {
        xbow:wrap-element($key, 'dt'),
        $map($key)
            => for-each(function ($user) {
                    ``[`{$user/@last}`, `{$user/@first}`: `{$user/@age}`]``
                })
        (: this will trigger an NPE :)
        (: => local:serialize-users():)
            => xbow:wrap-each('dd')
    }

    return $seq
        => for-each($f)
};

element html {
    element body {
        (: how many users last name begins with letter 'H'? :)
        $local:xml//user
            => xbow:groupBy(local:first-letter-of-last#1)
            => xbow:pluck('H')
            => count()
            => xbow:wrap-element('h1')
        ,
        (: group users by age :)
        $local:xml//user
            => xbow:groupBy(local:age-group#1)
            => local:serialize-map-sorted-b(('children', 'teens', 'twens', 'adults', 'seniors', 'miracle'))
            => xbow:wrap-element('dl')
        ,
        (: minimum maximum and average age :)
        $local:xml//user
            => for-each(function ($item) { xs:integer($item/@age) })
            => xbow:num-stats()
            => xbow:map-filter-keys(('min', 'max', 'avg'))
            => local:serialize-map-sorted-a(('min', 'max', 'avg'))
            => xbow:wrap-element('dl')
    }
}
 