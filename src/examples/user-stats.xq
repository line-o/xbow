xquery version '3.1';

declare namespace output = 'http://www.w3.org/2010/xslt-xquery-serialization';

import module namespace xbow = 'http://line-o.de/xq/xbow';

declare variable $local:xml := <root>
	<user age="8" first="Susan" last="Young" />
	<user age="31" first="Ike" last="Hurst" />
	<user age="50" first="Marla" last="Hill" />
	<user age="41" first="Paula" last="Meyer" />
	<user age="72" first="Fela" last="Kuti" />
	<user age="123" first="Mike" last="Heiner" />
	<user age="53" first="Carla" last="Hill" />
	<user age="15" first="Chris" last="Christie" />
	<user age="41" first="Paula" last="Meyer" />
	<user age="34" first="Fela" last="Mack" />
</root>;

declare variable $local:age-category-rules := [
	xbow:lt(12),
	xbow:lt(20),
	xbow:lt(30),
	xbow:lt(60),
	xbow:lt(120),
	xbow:ge(120)
];

declare function local:user-age ($item as node()) as xs:integer {
	xs:integer($item/@age)
};

declare function local:first-letter-of-last-name ($item) {
	substring($item/@last, 1, 1)
};

declare function local:serialize-users ($users as element(user)*) {
	if (empty($users)) then (
		'none'
	) else (
		for-each($users, function ($user) { ``[`{$user/@last}`, `{$user/@first}`: `{$user/@age}`]`` })
	)
};

declare function local:identity ($i) {
	$i
};

declare function local:render-stats ($map, $seq) {
	for-each(
		$seq,
		function ($key) { xbow:wrap-element($key, 'dt'), $map($key) => xbow:wrap-each('dd') }
	)
};

declare function local:render-user-age-category ($cat) {
	xbow:wrap-element($cat?label, 'dt'),
	if (empty($cat?items)) then (
		<dd>none</dd>
	) else (
		$cat?items
			=> for-each(function ($user) { ``[`{$user/@last}`, `{$user/@first}`: `{$user/@age}`]`` })
			=> xbow:wrap-each('dd')
	)
};

declare option output:method 'html';
declare option output:media-type 'text/html';
declare option output:indent 'no';

element html {
	element body {
		element h1 { 'User Stats' },
		element p {
			'useless stat of the day: ',
			(: how many users last name begins with letter 'H'? :)
			$local:xml//user
				=> xbow:groupBy(local:first-letter-of-last-name#1)
				=> xbow:pluck('H')
				=> count()
				=> concat(" user's lastnames start with the letter H")
				=> xbow:wrap-element('strong')
		},
		element h2 { 'By Age Category' },
		(: group users by age :)
		$local:xml//user
			=> xbow:categorize($local:age-category-rules, local:user-age#1)
			=> xbow:label(['children', 'teens', 'twens', 'adults', 'seniors', 'miracle'])
			=> array:for-each(local:render-user-age-category#1)
			=> xbow:wrap-element('dl'),
		element h2 { 'Age Stats' },
		(: minimum, maximum and average age :)
		$local:xml//user
			=> for-each(local:user-age#1)
			=> xbow:num-stats()
			=> local:render-stats(('min', 'max', 'avg'))
			=> xbow:wrap-element('dl')
	}
}
