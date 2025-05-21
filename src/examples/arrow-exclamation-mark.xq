xquery version '3.1';

declare function local:add ($a, $b) {
	$a + $b
};

declare function local:for-each-add ($s, $a) {
	for-each($s, local:add($a, ?))
};

(0 to 9)
		(:    => (function ($a) { $a ! string(.) })():)
		=> string-join()
		=> (
			function ($a) {
				$a || '&#x13;'
			}
		)()
		=> string-to-codepoints()
		=> (
			function ($a) {
				$a!(. + 1)
			}
		)()
		=> sum(),
	(1 to 10)
		=> for-each(local:add(-1, ?))
		(:    => for-each(string#1) :)
		=> string-join()
		=> concat('&#x13;')
		=> string-to-codepoints()
		=> local:for-each-add(1)
		=> sum(),
	(
		(1 to 10)!(. - 1)
			(:      ! string(.) :)
			=> string-join()
			=> concat('&#x13;')
			=> string-to-codepoints()
	)!(. + 1)
		=> sum()