# testing holonomy  decomposition
gap> START_TEST("Sgpdec package: holonomy.tst");
gap> LoadPackage("sgpdec", false);;
gap> hcs := HolonomyCascadeSemigroup(FullTransformationSemigroup(3));
<cascade semigroup with 3 generators, 2 levels with (3, 2) pts>
gap> hom := HomomorphismTransformationSemigroup(hcs);
MappingByFunction( <cascade semigroup with 3 generators, 2 levels with (3, 2) \
pts>, <transformation semigroup of degree 3 with 3 generators>
 , function( ct ) ... end )
gap> Size(Range(hom));
27
gap> hl := HolonomyRelationalMorphism(FullTransformationSemigroup(3));
MappingByFunction( <full transformation monoid of degree 3>, <cascade semigrou\
p with 3 generators, 2 levels with (3, 2) pts>, function( t ) ... end )
gap> Size(Range(hl));
30
gap> S := Semigroup([
> Transformation([1,2,3,1,1,1]),
> Transformation([4,4,4,5,4,6]),
> Transformation([4,4,4,5,6,4]),
> Transformation([4,4,4,4,5,5]),
> Transformation([4,4,4,1,2,3]),
> Transformation([2,3,1,4,4,4])]);;
> sk := Skeleton(S);;
gap> AllHolonomyCoords(1,sk);
[ [ 1, 1, 1, 1, 2 ], [ 1, 1, 1, 2, 1 ], [ 1, 2, 4, 1, 1 ] ]
gap> ForAll([1..6], x -> x=AsPoint(AsHolonomyCoords(x,sk),sk));
true
gap> hcs := HolonomyCascadeSemigroup(S);
<cascade semigroup with 6 generators, 5 levels with (2, 4, 5, 5, 2) pts>
gap> Display(hcs);
1: 2
2: (4,C3)
3: (3,S3) (2,C2)
4: (3,C3) (2,C2)
5: 2
gap> hom := HomomorphismTransformationSemigroup(hcs);
MappingByFunction( <cascade semigroup with 6 generators, 5 levels with (2, 4, \
5, 5, 2) pts>, <transformation semigroup of degree 6 with 6 generators>
 , function( ct ) ... end )
gap> AsSortedList(S) = AsSortedList(Range(hom));
true
gap> S := Semigroup([ Transformation( [ 1, 1 ] ), Transformation( [ 2, 2 ] ), 
>   Transformation( [ 3, 2, 3 ] ), Transformation( [ 1, 2, 3, 3, 5, 5 ] ), 
>   Transformation( [ 1, 2, 4, 4, 6, 6 ] ), 
>   Transformation( [ 1, 2, 3, 4, 3, 4 ] ), 
>   Transformation( [ 1, 2, 5, 6, 5, 6 ] ), 
>   Transformation( [ 1, 2, 3, 4, 5, 2 ] ) ]);;
gap> SgpDecOptionsRec.SMALL_GROUPS := true;;
gap> DisplayHolonomyComponents(Skeleton(S));
1: 5
2: 4
3: 4 3
4: (4,C2) 3
5: (3,C3) 2
6: (2,C2)
gap> SgpDecOptionsRec.SMALL_GROUPS := false;;
gap> DisplayHolonomyComponents(Skeleton(S));
1: 5
2: 4
3: 4 3
4: (4,|G|=2) 3
5: (3,|G|=3) 2
6: (2,|G|=2)
gap> SgpDecOptionsRec.SMALL_GROUPS := true;; #the default
gap> BEX := Semigroup([ Transformation([1,2,1,1]), Transformation([4,4,4,3]), Transformation([3,3,4,4]), Transformation([4,4,1,2]), Transformation([2,1,4,4])]);;
gap> TestHolonomyEmulation(BEX);
true
gap> TestHolonomyRelationalMorphism(Skeleton(BEX));
true
gap> TestHolonomyAction(BEX);
true

#
gap> STOP_TEST( "Sgpdec package: holonomy.tst", 10000);
