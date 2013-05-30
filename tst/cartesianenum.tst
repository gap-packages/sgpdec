# not SgpDec stuff, but good to test
gap> START_TEST("Sgpdec package: cartesianenum.tst");
gap> LoadPackage("sgpdec", false);;
gap> SemigroupsStartTest();
gap> eocp := EnumeratorOfCartesianProduct([
>                [1..55],
>                ['a','b','c'],
>                [1..33],
>                ["foo","bar"]
>            ]);;
gap> ForAll([1..Size(eocp)], i -> i = PositionCanonical(eocp,eocp[i]));
true

#
gap> SemigroupsStopTest();
gap> STOP_TEST( "Sgpdec package: cartesianenum.tst", 10000);