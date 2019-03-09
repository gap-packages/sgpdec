# not SgpDec stuff, but good to test
# Checking lazy cartesian product. It looks a bit circular, testing whether the
# index really gives the indexed element. This makes sense since nothing is
# stored. Elements are generated on the fly.
gap> START_TEST("Sgpdec package: cartesianenum.tst");
gap> LoadPackage("sgpdec", false);;
gap> eocp := EnumeratorOfCartesianProduct([
>                [1..55],
>                ['a','b','c'],
>                [1..33],
>                ["foo","bar"]
>            ]);;
gap> ForAll([1..Size(eocp)], i -> i = PositionCanonical(eocp,eocp[i]));
true

#
gap> STOP_TEST( "Sgpdec package: cartesianenum.tst", 10000);
