# testing holonomy  decomposition
gap> START_TEST("Sgpdec package: skeleton.tst");
gap> LoadPackage("sgpdec", false);;
gap> SemigroupsStartTest();
gap> sk := Skeleton(FullTransformationSemigroup(5));;
gap> IsSubductionRelated(sk,FiniteSet([1,3,5],5), FiniteSet([2],5));
false
gap> IsSubductionRelated(sk,FiniteSet([1],5), FiniteSet([2,4,5],5));
true
gap> SemigroupsStopTest();
gap> STOP_TEST( "Sgpdec package: skeleton.tst", 10000);
