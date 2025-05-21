xquery version '3.1';

import module namespace xbow = 'http://line-o.de/xq/xbow';

let $data :=
	<persons>
    <person posts="3" name="Berta" />
    <person posts="1" name="Anne" />
    <person posts="17" name="Jules" />
    <person posts="4" name="Carl" />
    <person posts="54" name="Maude" />
    <person posts="5" name="Diraj" />
    <person posts="6" name="Eero" />
    <person posts="70" name="Franka" />
    <person posts="8" name="Gustav" />
    <person posts="9" name="Horst" />
    <person posts="34" name="Klaus" />
    <person posts="9" name="Isabella" />
    <person posts="45" name="Laura" />
</persons>
let $activity-rules := [xbow:lt(5), xbow:lt(20), xbow:ge(20)]
let $activity-labels := ['inactive', 'active', 'hyperactive']
let $post-accessor :=
	function ($i as element(person)) {
		xs:integer($i/@posts)
	}
return $data/person => xbow:categorize($activity-rules, $post-accessor) => xbow:label($activity-labels)