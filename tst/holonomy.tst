# testing holonomy  decomposition
gap> START_TEST("Sgpdec package: holonomy.tst");
gap> LoadPackage("sgpdec", false);;
gap> SemigroupsStartTest();
gap> hcs := HolonomyCascadeSemigroup(FullTransformationSemigroup(3));
<cascade semigroup with 4 generators, 2 levels with (3, 2) pts>
gap> HomomorphismTransformationSemigroup(hcs);
MappingByFunction( <cascade semigroup with 4 generators, 2 levels with (3, 2) \
pts>, <transformation monoid on 3 pts with 3 generators>
 , function( c ) ... end )

#
gap> SemigroupsStopTest();
gap> STOP_TEST( "Sgpdec package: holonomy.tst", 10000);
