xquery version "3.1";

import module namespace xbow="http://line-o.de/xbow" at '/db/apps/xbow/xbow.xqm';
import module namespace functx="http://www.functx.com";

declare function local:wrapByLiteral ($i) as element(a) {
    <a b="{ $i }"/>
};

declare function local:wrapByElement ($i) as element(a) {
    element a { attribute b { $i }}
};


(1,2)
    => for-each(local:wrapByLiteral#1)
    => for-each(local:wrapByElement#1)
