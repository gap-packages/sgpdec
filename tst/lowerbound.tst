# testing lowerbound
gap> START_TEST("Sgpdec package: lowerbound.tst");
gap> LoadPackage("sgpdec", false);;
gap> SgpDecFiniteSetDisplayOn();;
gap> S := FullTransformationSemigroup(4);;
gap> sk := Skeleton(S);;
gap> CheckEssentialDependency(sk, 1,2);
Group([ (2,3), (1,2), (1,3) ])
gap> CheckEssentialDependency(sk, 2,3);
Group([ (1,2) ])
gap> SgpDecFiniteSetDisplayOff();;

#
gap> STOP_TEST( "Sgpdec package: lowerbound.tst", 10000);
