# transformation notation tests
# checking whether we can get back the transformation from 
# the string representation
gap> START_TEST("Sgpdec package: transnot.tst");
gap> LoadPackage("sgpdec", false);;
gap> ForAll([1..314],function(i)
>  local rnd;
>  rnd := RandomTransformation(163);
>  return rnd = AsTransformation(LinearNotation(rnd),163);
>  end);
true

#
gap> STOP_TEST( "Sgpdec package: transnot.tst", 10000);