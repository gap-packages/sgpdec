# transformation notation tests
# checking whether we can get back the transformation from 
# the string representation
gap> START_TEST("Sgpdec package: transnot.tst");
gap> LoadPackage("sgpdec", false);;
gap> t := Transformation([1,7,14,4,3,10,5,10,10,9,14,9,13,6,8,11]);;
gap> AttractorCycleNotation(t);
"([[[[2,7,5,3]|[16,11],14],6]|[15,8],10],[12,9])"

#
gap> STOP_TEST( "Sgpdec package: transnot.tst", 10000);
