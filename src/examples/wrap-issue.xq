xquery version '3.1';

(:~
 : If this runs without throwing an exception about duplicate attributes
 : then you can safely use all the element and attribute helpers of xbow 
~:)

declare function local:wrapWithElementLiteral ($i) as element(a) {
	<a b="{
		$i
	}"/>
};

declare function local:wrapWithElementConstructor ($i) as element(a) {
	element a {
		attribute b {
			$i
		}
	}
};

(1, 2) => for-each(local:wrapWithElementLiteral#1), (1, 2) => for-each(local:wrapWithElementConstructor#1)