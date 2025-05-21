xquery version '3.1';

module namespace xbow-categorize-spec = 'http://line-o.de/xbow/categorize-spec';
declare namespace test = 'http://exist-db.org/xquery/xqsuite';

import module namespace xbow-spec = 'http://line-o.de/xq/xbow/spec';
import module namespace xbow = 'http://line-o.de/xq/xbow';

declare %test:assertEquals(2) function xbow-categorize-spec:numbers () {
	(-10 to 10) => xbow:categorize([xbow:lt(0), xbow:ge(0)]) => array:size()
};

declare %test:assertEquals(0) function xbow-categorize-spec:none-match () {
	(0 to 10)
		=> xbow:categorize([xbow:lt(0), xbow:gt(10)])
		=> (
			function ($arr) {
				(count($arr?1), count($arr?2)) => sum()
			}
		)()
};

declare %test:assertEquals(2) function xbow-categorize-spec:number-of-categories () {
	$xbow-spec:user-xml/user => xbow:categorize([xbow:lt(21), xbow:ge(21)], xbow-spec:age-accessor#1) => array:size()
};

declare %test:assertEquals('2', '8') function xbow-categorize-spec:number-of-items () {
	$xbow-spec:user-xml/user
		=> xbow:categorize([xbow:lt(21), xbow:ge(21)], xbow-spec:age-accessor#1)
		=> array:for-each(
			function ($items) {
				count($items)
			}
		)
		=> xbow:to-sequence()
};

declare %test:assertEquals('<user first=&quot;Susan&quot; last=&quot;Young&quot; age=&quot;8&quot;/>',
	'<user first=&quot;Chris&quot; last=&quot;Christie&quot; age=&quot;15&quot;/>')
	function xbow-categorize-spec:items () {
	$xbow-spec:user-xml/user
		=> xbow:categorize([xbow:lt(21), xbow:ge(21)], xbow-spec:age-accessor#1)
		=> (
			function ($arr) {
				$arr?1
			}
		)()
};

declare %test:assertEquals('underage', '2') function xbow-categorize-spec:label-items () {
	$xbow-spec:user-xml/user
		=> xbow:categorize([xbow:lt(21), xbow:ge(21)], xbow-spec:age-accessor#1)
		=> xbow:label(['underage', 'adult'])
		=> (
			function ($arr) {
				$arr?1?label, count($arr?1?items)
			}
		)()
};



