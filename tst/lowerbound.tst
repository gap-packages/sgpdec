# testing lowerbound
gap> START_TEST("Sgpdec package: lowerbound.tst");
gap> LoadPackage("sgpdec", false);;
gap> SgpDecFiniteSetDisplayOn();;
gap> S := FullTransformationSemigroup(4);;
gap> sk := Skeleton(S);;
gap> StructureDescription(CheckEssentialDependency(sk, 1,2));
"S3"
gap> StructureDescription(CheckEssentialDependency(sk, 2,3));
"C2"

# testing max chain of essential dependency
gap> S := FullTransformationSemigroup(6);;
gap> sk := Skeleton(S);;
gap> MaxChainOfEssentialDependency(sk);
[ 1, 2, 3, 4, 5 ]
gap> #Krebs Cycle Example from Rhodes (2010) Figure 3 Part I:
gap> alpha:=   Transformation([2,2,4,4,5,2]);;  #NAD
gap> beta:=     Transformation([1,3,3,4,5,6]);;  #NADP
gap> gamma:=Transformation([1,2,3,5,5,6]);;  #GDP
gap> delta:=    Transformation([1,2,3,4,6,6]);;  #NADP
gap> KrebsK2:=Semigroup(alpha,beta, gamma,delta);;;
gap> skel:=Skeleton(KrebsK2);;
gap> StructureDescription(CheckEssentialDependency(skel,5,6));
"C2"
gap> MaxChainOfEssentialDependency(sk);
[ 1, 2, 3, 4, 5 ]
gap> STOP_TEST( "Sgpdec package: lowerbound.tst", 10000);
