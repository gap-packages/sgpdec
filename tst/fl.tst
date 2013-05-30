# testing the Frobenius-Lagrange decomposition
gap> START_TEST("Sgpdec package: fl.tst");
gap> LoadPackage("sgpdec", false);;
gap> SemigroupsStartTest();
gap> flG := FLCascadeGroup(SymmetricGroup(IsPermGroup,3));
<cascade group with 2 generators, 2 levels with (2, 3) pts>
gap> Range(IsomorphismPermGroup(flG));
Group([ (1,2,3), (1,2) ])
gap> Range(IsomorphismPermGroup(Group(GeneratorsOfGroup(flG))));
Group([ (1,3,2)(4,5,6), (1,5)(2,6)(3,4) ])
gap> G := DihedralGroup(IsPermGroup,24);
Group([ (1,2,3,4,5,6,7,8,9,10,11,12), (2,12)(3,11)(4,10)(5,9)(6,8) ])
gap> IsomorphismGroups(G, FLCascadeGroup(G));
[ (1,2,3,4,5,6,7,8,9,10,11,12), (2,12)(3,11)(4,10)(5,9)(6,8) ] -> 
[ <perm cascade with 4 levels with (2, 2, 2, 3) pts, 6 dependencies>, 
  <perm cascade with 4 levels with (2, 2, 2, 3) pts, 1 dependencies> ]

#
gap> SemigroupsStopTest();
gap> STOP_TEST( "Sgpdec package: fl.tst", 10000);