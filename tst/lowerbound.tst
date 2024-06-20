gap> START_TEST("Sgpdec package: lowerbound.tst");
gap> LoadPackage("sgpdec", false);;
gap> SgpDecFiniteSetDisplayOn();;

# Testing Becks++
gap> beckspp := [
> Transformation([1,2,3,1,1,1]),
> Transformation([4,4,4,5,4,6]),
> Transformation([4,4,4,5,6,4]),
> Transformation([4,4,4,4,5,5]),
>                               
> Transformation([4,4,4,1,2,3]),
> Transformation([2,3,1,4,4,4]),
> Transformation([2,1,3,4,2,2]),
> Transformation([1,2,2,2,2,2])];;#makes H({1,2,3}) nontrivia
gap> BECKSPP := Semigroup(beckspp);;
gap> skel := Skeleton(BECKSPP);;
gap> EssentialDependencyGroup(skel, FiniteSet([1,2,3], 6), FiniteSet([1,2], 6));
Group([ (1,2) ])
gap> EssentialDependencyGroup(skel, FiniteSet([1,2,3,4], 6), FiniteSet([1,2,3], 6));
Group(())
gap> EssentialDependencyGroup(skel, FiniteSet([4,5,6], 6), FiniteSet([4,5], 6));
Group([ (4,5) ])
gap> EssentialDependencyGroup(skel, FiniteSet([1,2,3,4], 6), FiniteSet([4,5], 6));
Group(())
gap> MaxChainOfEssentialDependency(skel);
Maximum Chain Found:{1,2,3} -> {1,2}
2

# Testing full semigroup
gap> S := FullTransformationSemigroup(4);;
gap> sk := Skeleton(S);;
gap> MaxChainOfEssentialDependency(sk);
Maximum Chain Found:{1,2,3,4} -> {1,2,3} -> {1,2}
3
gap> StructureDescription(EssentialDependencyGroup(sk, FiniteSet([1,2,3,4], 4), FiniteSet([1,2,3], 4)));
"S3"

# Testing Krebs cycle example
gap> alpha:=   Transformation([2,2,4,4,5,2]);;  #NAD
gap> beta:=     Transformation([1,3,3,4,5,6]);;  #NADP
gap> gamma:=Transformation([1,2,3,5,5,6]);;  #GDP
gap> delta:=    Transformation([1,2,3,4,6,6]);;  #NADP
gap> KrebsK2:=Semigroup(alpha,beta, gamma,delta);;;
gap> skel:=Skeleton(KrebsK2);;
gap> MaxChainOfEssentialDependency(skel);
Maximum Chain Found:{2,4,5} -> {2,4}
2
gap> EssentialDependencyGroup(skel, FiniteSet([2,4,5], 6), FiniteSet([2,5], 6));
Group([ (2,5) ])
gap> STOP_TEST( "Sgpdec package: lowerbound.tst", 10000);
