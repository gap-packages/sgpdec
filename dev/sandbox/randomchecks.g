SetInfoLevel(SkeletonInfoClass,2);
SetInfoLevel(HolonomyInfoClass,2);

for i in [1..100]  do
 gens := List([1..6], x-> RandomTransformation(8));
 hd := HolonomyDecomposition(Semigroup(gens));
 holonomy_testAction(hd);
 holonomy_testCoordinates(hd); 
 holonomy_testRaiseFlatten(hd); 
 holonomy_testProducts(hd);
od;
