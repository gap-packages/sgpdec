# testing weak control words
gap> START_TEST("Sgpdec package: WeakControlWords.tst");
gap> LoadPackage("sgpdec", false);;
gap> SgpDecFiniteSetDisplayOn();;
gap> S:=FullTransformationSemigroup(5);
<full transformation monoid of degree 5>
gap> gens:=Generators(S);
[ Transformation( [ 2, 3, 4, 5, 1 ] ), Transformation( [ 2, 1 ] ), 
  Transformation( [ 1, 2, 3, 4, 1 ] ) ]
gap> x := FiniteSet([2,3,4,5],5);
{2,3,4,5}
gap> y := FiniteSet([1,4],5);
{1,4}
gap> wcw := WeakControlWords(Skeleton(S),y,x);
fail
gap> wcw := WeakControlWords(Skeleton(S),x,y);
[ [ 3 ], [ 1, 1, 3, 1, 2, 3 ] ]
gap> t1 := BuildByWord(wcw[1],gens,IdentityTransformation,\*);
Transformation( [ 1, 2, 3, 4, 1 ] )
gap> x1 := OnFiniteSet(x,t1);
{1,2,3,4}
gap> IsSubductionEquivalent(Skeleton(S),x,x1);
true
gap> t2 := BuildByWord(wcw[2],gens,IdentityTransformation,\*);
Transformation( [ 4, 1, 1, 1, 3 ] )
gap> OnFiniteSet(x1,t2);
{1,4}
gap> OnFiniteSet(x1,t2)=y;
true
gap> IsSubset(y,x1);
true
gap> SgpDecFiniteSetDisplayOn();;

#
gap> STOP_TEST( "Sgpdec package: WeakControlWords.tst", 10000);
