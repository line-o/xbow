xquery version "3.1";

import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";


(
  "xbow-spec.xqm",
  "xbow-categorize-spec.xqm",
  "xbow-type-spec.xqm",
  "xbow-node-constructor-spec.xqm"
)
=> for-each(xs:anyURI#1)
=> for-each(inspect:module-functions#1)
=> test:suite()
