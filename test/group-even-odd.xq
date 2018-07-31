xquery version "3.1";

import module namespace xbow="http://line-o.de/xbow";

declare function local:even-odd ($item as xs:numeric) as xs:string {
  if ($next mod 2) then ('odd') else ('even')
}

(: group by even and odd :)
(0 to 9)
  => xbow:groupBy(local:even-odd#1)
