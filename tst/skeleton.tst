# testing holonomy  decomposition
gap> START_TEST("Sgpdec package: skeleton.tst");
gap> LoadPackage("sgpdec", false);;
gap> SgpDecFiniteSetDisplayOn();;
gap> sk := Skeleton(FullTransformationSemigroup(5));;
gap> IsSubductionLessOrEquivalent(sk,FiniteSet([1,3,5],5), FiniteSet([2],5));
false
gap> IsSubductionLessOrEquivalent(sk,FiniteSet([1],5), FiniteSet([2,4,5],5));
true

#becks
gap> gens := [
> Transformation([1,2,3,1,1,1]), Transformation([4,4,4,5,4,6]),
> Transformation([4,4,4,5,6,4]), Transformation([4,4,4,4,5,5]),
> Transformation([4,4,4,1,2,3]), Transformation([2,3,1,4,4,4])];;
gap> sk := Skeleton(Semigroup(gens));;
gap> P := FiniteSet([4,5],6);;
gap> Q := FiniteSet([3,4],6);;
gap> IsSubsetBlist(OnFiniteSet(Q, EvalWordInSkeleton(sk,
>        SubductionWitness(sk,P,Q))),P);
true
gap> ExtendedImageSet(sk);
[ {1,2,3,4,5,6}, {1,2,3,4}, {1,2,3}, {4,5,6}, {1,2}, {1,3}, {1,4}, {2,3}, 
  {2,4}, {3,4}, {4,5}, {4,6}, {5,6}, {1}, {2}, {3}, {4}, {5}, {6} ]
gap> Interpret(sk, 1,1);
{1,2,3,4}

#number of tile chains
gap> d := DegreeOfSkeleton(sk);;
gap> ForAll([1..d], x -> NrChainsBetween(sk,BaseSet(sk),FiniteSet([x],d)) = Size(ChainsBetween(sk, BaseSet(sk),FiniteSet([x],d))));
true
gap> DominatingChains(sk, [FiniteSet([1],6)]);
[ [ {1,2,3,4,5,6}, {1,2,3,4}, {1,2,3}, {1,2}, {1} ], 
  [ {1,2,3,4,5,6}, {1,2,3,4}, {1,2,3}, {1,3}, {1} ], 
  [ {1,2,3,4,5,6}, {1,2,3,4}, {1,4}, {1} ] ]
gap> sk := Skeleton(Semigroup(Transformation([5,5,5,5,5])));;
gap> ExtendedImageSet(sk);
[ {1,2,3,4,5}, {1}, {2}, {3}, {4}, {5} ]
gap> NonImageSingletonClasses(sk);
[ [ {4} ], [ {3} ], [ {2} ], [ {1} ] ]
gap> HolonomyInfoString(sk);
"2 2 5 5,1"
gap> SgpDecRunManualExamples();
# Running list 1 . . .
# Running list 2 . . .
# Running list 3 . . .
# Running list 4 . . .
# Running list 5 . . .
# Running list 6 . . .
# Running list 7 . . .
# Running list 8 . . .
# Running list 9 . . .
# Running list 10 . . .
# Running list 11 . . .
# Running list 12 . . .
# Running list 13 . . .
# Running list 14 . . .
# Running list 15 . . .
# Running list 16 . . .
# Running list 17 . . .
gap> SgpDecFiniteSetDisplayOff();;

#
gap> STOP_TEST( "Sgpdec package: skeleton.tst", 10000);
