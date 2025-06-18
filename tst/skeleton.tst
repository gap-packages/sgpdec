# testing holonomy  decomposition
gap> START_TEST("Sgpdec package: skeleton.tst");
gap> LoadPackage("sgpdec", false);;
gap> SgpDecFiniteSetDisplayOn();;

#testing subduction in the T5
gap> sk := Skeleton(FullTransformationSemigroup(5));;
gap> IsSubductionLessOrEquivalent(sk,FiniteSet([1,3,5],5), FiniteSet([2],5));
false
gap> IsSubductionLessOrEquivalent(sk,FiniteSet([1],5), FiniteSet([2,4,5],5));
true

#testing representatives
gap> RepresentativeSets(sk);
[ [ {1,2,3,4,5} ], [ {1,2,3,4} ], [ {1,2,3} ], [ {1,3} ], [ {1} ] ]
gap> sk2 := MakeRepresentative(sk, FiniteSet([3,4,5],5));;
gap> RepresentativeSets(sk2);
[ [ {1,2,3,4,5} ], [ {1,2,3,4} ], [ {3,4,5} ], [ {1,3} ], [ {1} ] ]

#this was a bug in the 2023.08 rewrite
gap>  ts := Semigroup(Transformation([2,2,1,2,4]),Transformation([3,5,2,3,2]), Transformation([3,5,4,5,4]));;
gap> sk := Skeleton(ts);;
gap> IsSubductionLessOrEquivalent(sk, FiniteSet([1,2],5), FiniteSet([2,5],5));
true
gap> SubductionWitness(sk, FiniteSet([1,2],5), FiniteSet([2,5],5));
[ 3, 2, 1 ]

#extended image set for a constant monoid
gap> S := Semigroup(Transformation([5,5,5,5,5]));;
gap> sk := Skeleton(S);;
gap> Display(sk);
<skeleton of Semigroup( [ Transformation( [ 5, 5, 5, 5, 5 ] ) ] )>
gap> SortedExtendedImageSet(sk);
[ {1,2,3,4,5}, {1}, {2}, {3}, {4}, {5} ]
gap> ImageWitness(sk, FiniteSet([1..5]), FiniteSet([5]));
fail
gap> ImageWitness(sk, FiniteSet([5]), FiniteSet([1..5]));
[ 1 ]

#testing for a semigroup with no singleton image - they should not be reported in the depth
gap> sk := Skeleton(Semigroup(Transformation([4,2,4,4])));;
gap> DepthOfSkeleton(sk);
3
gap> TilesOf(sk, FiniteSet([1,3],4));
fail

#nontrivial class for nonimage singletons
gap> sk := Skeleton(Semigroup(Transformation([1,3,3,3]), Transformation([1,2,4,3])));;
gap> NonImageSingletons(sk);
[ {1}, {2}, {3}, {4} ]
gap> NonImageSingletonClasses(sk);
[ [ {4}, {3} ], [ {2} ], [ {1} ] ]

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
gap> SortedExtendedImageSet(sk);
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
gap> SortedExtendedImageSet(sk);
[ {1,2,3,4,5}, {1}, {2}, {3}, {4}, {5} ]
gap> NonImageSingletonClasses(sk);
[ [ {4} ], [ {3} ], [ {2} ], [ {1} ] ]
gap> HolonomyInfoString(sk);
"2 2 5 5,1"
gap> PermutatorSemigroupElts(FullTransformationSemigroup(3), FiniteSet([1,2],3));
[ Transformation( [ 1, 2, 1 ] ), Transformation( [ 1, 2, 2 ] ), 
  IdentityTransformation, Transformation( [ 2, 1, 1 ] ), 
  Transformation( [ 2, 1, 2 ] ), Transformation( [ 2, 1 ] ) ]
gap> SgpDecFiniteSetDisplayOff();;

#
gap> STOP_TEST( "Sgpdec package: skeleton.tst", 10000);
