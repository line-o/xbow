xquery version "3.1";


import module namespace test="http://exist-db.org/xquery/xqsuite" 
  at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";


declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:media-type "application/json";


let $version := request:get-parameter('version', '1.0.0')
let $lib := request:get-parameter('lib', 'xbow')
let $uri := ``[xmldb:///db/system/repo/`{$lib}`-`{$version}`/test/`{$lib}`-spec.xqm]``

return
try {
    let $result :=
        xs:anyURI($uri)
            => inspect:module-functions()
            => test:suite()

    let $json := map {
        "result": map {
            "errors": $result//testsuite/@errors => xs:integer(),
            "tests": $result//testsuite/@tests => xs:integer(),
            "time": $result//testsuite/@time => xs:dayTimeDuration() => seconds-from-duration(),
            "timestamp": $result//testsuite/@timestamp/string(),
            "failures": $result//testsuite/@failures => xs:integer(),
            "pending": $result//testsuite/@pending => xs:integer()
        }
    }    

    return (
        util:log('info', $json),
        $json
    )
}
catch * {
    util:log('error', $err:description),
    map {
        "error": map {
            "lib": $lib,
            "version": $version,
            "uri": $uri,
            "code": $err:code,
            "value": $err:value,
            "description": $err:description
        }
    }
}