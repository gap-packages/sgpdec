# attractor-cycle transformation notation tests
# checking whether we can get back the transformation from 
# the string representation
gap> START_TEST("Attractor-Cycle Notation");
gap> LoadPackage("sgpdec", false);;
gap> t := Transformation([1,7,14,4,3,10,5,10,10,9,14,9,13,6,8,11]);;
gap> AttractorCycleNotation(t);
"([[[[2,7,5,3]|[16,11],14],6]|[15,8],10],[12,9])"
gap> AsTransformation("[[1|2,3],4]",4);                                                          
Transformation( [ 3, 3, 4, 4 ] )

#
#gap> AsTransformation("[1|2,3,4]",4); #now we consider this malformed, it does not work with a clean parsing algorithm
#Transformation( [ 3, 3, 4, 4 ] )
# full check for T5
gap> ACNTestFullTransformationSemigroup(6); 
true

# bigger tests
gap> t := RandomTransformation(2^12);;
gap> t = AsTransformation(AttractorCycleNotation(t),2^12);
true
gap> t := RandomTransformation(2^12,2^5);;
gap> t = AsTransformation(AttractorCycleNotation(t),2^12);
true

# simplified constant
gap> SimplerAttractorCycleNotation(Transformation([5,5,5,5,5]));
"5"
gap> SimplerAttractorCycleNotation(Transformation([1,5,5,5,5]));
"[2|3|4,5]"
gap> SimplerAttractorCycleNotation(Transformation([2,5,5,5,5]));
"[[1,2]|3|4,5]"

#
gap> STOP_TEST( "Attractor-Cycle Notation");
