xquery version "3.1";

declare function local:wrapByLiteral ($i) as element(a) {
    <a b="{ $i }"/>
};

declare function local:wrapByElement ($i) as element(a) {
    element a { attribute b { $i }}
};


(1,2)
    => for-each(local:wrapByLiteral#1)
    => for-each(local:wrapByElement#1)
