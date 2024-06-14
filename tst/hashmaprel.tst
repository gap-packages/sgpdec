gap> START_TEST("Relations represented by HashMaps");
gap> LoadPackage("sgpdec", false);;
gap> hmr := HashMap([[1,[2,3]],[2,[3]]]);
HashMap([[ 1, [ 2, 3 ] ], [ 2, [ 3 ] ]])
gap> ImageOfHashMapRelation(hmr);
[ 2, 3 ]
gap> IsInjectiveHashMapRelation(hmr);
false
gap> IsInjectiveHashMapRelation2(hmr);
false
gap> hmr := HashMap([[1,[2,3]],[2,[4,5,6]]]);
HashMap([[ 1, [ 2, 3 ] ], [ 2, [ 4, 5, 6 ] ]])
gap> IsInjectiveHashMapRelation2(hmr);
true
gap> IsInjectiveHashMapRelation(hmr);
true
gap> InvertHashMapRelation(hmr);
HashMap([[ 2, [ 1 ] ], [ 3, [ 1 ] ], [ 4, [ 2 ] ], [ 5, [ 2 ] ], [ 6, [ 2 ] ]])
gap> STOP_TEST( "Relations represented by HashMaps");
