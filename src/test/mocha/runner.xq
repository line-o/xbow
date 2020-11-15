xquery version "3.1";


import module namespace test="http://exist-db.org/xquery/xqsuite" 
    at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";


declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:media-type "application/json";

declare
function local:get-module-uri ($lib as xs:string, $version as xs:string) as xs:string* {
    xs:anyURI(
        ``[xmldb:///db/system/repo/`{$lib}`-`{$version}`/test/`{$lib}`-spec.xqm]``)
};

declare
function local:result-to-map ($result as element()) as map(*) {
    map {
        "result": map {
            "errors": $result//testsuite/@errors => xs:integer(),
            "tests": $result//testsuite/@tests => xs:integer(),
            "time": $result//testsuite/@time => xs:dayTimeDuration() => seconds-from-duration(),
            "timestamp": $result//testsuite/@timestamp/string(),
            "failures": $result//testsuite/@failures => xs:integer(),
            "pending": $result//testsuite/@pending => xs:integer()
        }
    }
};

declare variable $local:lib := request:get-parameter('lib', ());
declare variable $local:version := request:get-parameter('version', ());

try {
    let $result := 
        local:get-module-uri($local:lib, $local:version)
            => inspect:module-functions()
            => test:suite()
            => local:result-to-map()

    return (
        $result,
        util:log('info', $result)
    )
}
catch * {
    map {
        "error": map {
            "lib": $local:lib,
            "version": $local:version,
            "code": $err:code,
            "value": $err:value,
            "description": $err:description
        }
    },
    util:log('error', $err:description)
}