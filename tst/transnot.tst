# transformation notation tests
# checking whether we can get back the transformation from 
# the string representation
gap> START_TEST("Sgpdec package: transnot.tst");
gap> LoadPackage("sgpdec", false);;
gap> ForAll([1..10],function(i)
>  local rnd;
>  rnd := RandomTransformation(931);
>  return rnd = AsTransformation(LinearNotation(rnd),931);
>  end);
true
gap> LinearNotation(Transformation([5,5,5,5,5]));
"[1,2,3,4;5]"
gap> SimplerLinearNotation(Transformation([5,5,5,5,5]));
"[->5]"
gap> SimplerLinearNotation(Transformation([4,5,4,5,4,5]));
"([1,3;4],[2,6;5])"
gap> SimplerLinearNotation(Transformation([1]));
"()"
gap> SimplerLinearNotation(Transformation([1,2]));
"()"
gap> SimplerLinearNotation(Transformation([2,1]));
"(1,2)"
gap> SimplerLinearNotation(Transformation([5,5,5,2,2,2]));
"([1,3;5],[4,6;2])"
gap> SimplerLinearNotation(Transformation([1,1,1,2,2,2]));
"[[4,5,6;2],3;1]"

#
gap> STOP_TEST( "Sgpdec package: transnot.tst", 10000);
