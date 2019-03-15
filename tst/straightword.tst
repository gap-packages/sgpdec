# checking whether straight word reduction is really reduction and gives
# the same transformation
gap> START_TEST("Sgpdec package: straightword.tst");
gap> LoadPackage("sgpdec");;
gap> gens := GeneratorsOfSemigroup(FullTransformationSemigroup(9));;
gap> w := RandomWord(33333,Size(gens));;
gap> rw := Reduce2StraightWord(w,gens,One(gens[1]),\*);;
gap> Length(rw) <= Length(w);
true
gap> IsStraightWord(rw,gens,One(gens[1]),\*);
true
gap> IsStraightWord([1],[Transformation([1,1])],Transformation([1,1]),\*);
true
gap> IsStraightWord([1,1],[Transformation([1,1])],Transformation([1,1]),\*); #TODO maybe revise definition
false
gap> BuildByWord(w,gens,One(gens[1]),\*)
>       = BuildByWord(rw,gens,One(gens[1]),\*);
true
gap> l := [];; StraightWords(IdentityTransformation, Generators(FullTransformationSemigroup(2)), \*, SWP_SimpleCollector(l),10);;
gap> l;
[ [  ], [ 1 ], [ 1, 1 ], [ 1, 2 ], [ 1, 2, 1 ], [ 2 ], [ 2, 1 ] ]
gap> StraightWords(IdentityTransformation, Generators(FullTransformationSemigroup(2)), \*, SWP_Printer,10);;
IdentityTransformation:[  ]
Transformation( [ 2, 1 ] ):[ 1 ]
IdentityTransformation:[ 1, 1 ]
Transformation( [ 1, 1 ] ):[ 1, 2 ]
Transformation( [ 2, 2 ] ):[ 1, 2, 1 ]
Transformation( [ 1, 1 ] ):[ 2 ]
Transformation( [ 2, 2 ] ):[ 2, 1 ]
gap> l := [];; StraightWords(IdentityTransformation, Generators(FullTransformationSemigroup(2)), \*, SWP_Search(l,Transformation([1,2])),10);;
gap> l;
[ [  ], [ 1, 1 ] ]
gap> l := [];; StraightWords(IdentityTransformation, Generators(FullTransformationSemigroup(2)), \*, SWP_WordPointPairCollector(l),10);;
gap> l;
[ [ [  ], IdentityTransformation ], [ [ 1 ], Transformation( [ 2, 1 ] ) ], 
  [ [ 1, 1 ], IdentityTransformation ], 
  [ [ 1, 2 ], Transformation( [ 1, 1 ] ) ], 
  [ [ 1, 2, 1 ], Transformation( [ 2, 2 ] ) ], 
  [ [ 2 ], Transformation( [ 1, 1 ] ) ], 
  [ [ 2, 1 ], Transformation( [ 2, 2 ] ) ] ]

#
gap> STOP_TEST( "Sgpdec package: straightword.tst", 10000);
