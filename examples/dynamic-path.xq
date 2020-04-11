xquery version "3.1";


import module namespace xbow = 'http://line-o.de/xq/xbow';


declare variable $xml :=
    <a b="c">
        some
        <b d="3">text</b>
    </a>
;


(
    $xml
        => xbow:pluck('@b')
        => data(),
    $xml
        => xbow:pluck('b') 
        => xbow:pluck('@d') 
        => data(),
    $xml 
        => xbow:pluck('b/@d') 
        => string(),
    $xml 
        => xbow:pluck('./b/../b/@d') 
        => string()
)