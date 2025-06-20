xquery version '3.1';

import module namespace xbow = 'http://line-o.de/xq/xbow';

let $data := <persons>
	<person name="Berta" posts="3" />
	<person name="Anne" posts="1" />
	<person name="Jules" posts="17" />
	<person name="Carl" posts="4" />
	<person name="Maude" posts="54" />
	<person name="Diraj" posts="5" />
	<person name="Eero" posts="6" />
	<person name="Franka" posts="70" />
	<person name="Gustav" posts="8" />
	<person name="Horst" posts="9" />
	<person name="Klaus" posts="34" />
	<person name="Isabella" posts="9" />
	<person name="Laura" posts="45" />
</persons>

let $activity-rules := [xbow:lt(5), xbow:lt(20), xbow:ge(20)]
let $activity-labels := ['inactive', 'active', 'hyperactive']
let $post-accessor := function ($i as element(person)) { xs:integer($i/@posts) }

return $data/person
		=> xbow:categorize($activity-rules, $post-accessor)
		=> xbow:label($activity-labels)
