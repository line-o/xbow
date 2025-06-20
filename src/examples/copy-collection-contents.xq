xquery version '3.1';

declare function local:copy-collection-contents ($source, $target) {
	xmldb:get-child-resources($source) => for-each(xmldb:copy-resource($source, ?, $target, ?)),
	xmldb:get-child-collections($source)
		=> for-each(concat($source, '/', ?))
		=> for-each(xmldb:copy-collection(?, $target))
};

declare function local:copy-collection-contents-and-check ($source, $target) as xs:boolean {
	xmldb:get-child-resources($source)
		=> fold-left(
			true(),
			function ($result, $next) {
				let $action := xmldb:copy-resource($source, $next, $target, $next)
				return $result and exists($action)
			}
		) and
		xmldb:get-child-collections($source)
			=> for-each(concat($source, '/', ?))
			=> fold-left(
				true(),
				function ($result, $next) {
					let $action := xmldb:copy-collection($next, $target)
					return $result and exists($action)
				}
			)
};

if (local:copy-collection-contents-and-check('/db/a', '/db/b')) then
	'OK'
else
	'FAIL',
(: create /db/a :)
(: create /db/a/a.xml :)
(: create /db/a/aa :)
(: create /db/a/aa/aa.xml :)
(: create /db/a/ab :)
(: create /db/a/ab/ab.xml :)

local:copy-collection-contents('/db/a', '/db/b')
(: check contents of b :) 