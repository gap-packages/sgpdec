# testing the Frobenius-Lagrange decomposition
gap> START_TEST("Sgpdec package: fl.tst");
gap> LoadPackage("sgpdec", false);;
gap> flG := FLCascadeGroup(SymmetricGroup(IsPermGroup,3));
<cascade group with 2 generators, 2 levels with (2, 3) pts>
gap> Range(IsomorphismPermGroup(flG));
Group([ (1,2,3), (1,2) ])
gap> Range(IsomorphismPermGroup(Group(GeneratorsOfGroup(flG))));
Group([ (1,3,2)(4,5,6), (1,5)(2,6)(3,4) ])
gap> G := DihedralGroup(IsPermGroup,24);
Group([ (1,2,3,4,5,6,7,8,9,10,11,12), (2,12)(3,11)(4,10)(5,9)(6,8) ])
gap> IsomorphismGroups(FLCascadeGroup(G), G); #doesn't work the other way around
[ <perm cascade with 4 levels with (2, 2, 2, 3) pts, 6 dependencies>, 
  <perm cascade with 4 levels with (2, 2, 2, 3) pts, 1 dependencies> ] -> 
[ (1,2,3,4,5,6,7,8,9,10,11,12), (2,12)(3,11)(4,10)(5,9)(6,8) ]
gap> # example from the cube paper, random choice hardcoded
gap> pocket_cube_F := (9,10,11,12)(4,13,22,7)(3,16,21,6);;
gap> pocket_cube_R := (13,14,15,16)(2,20,22,10)(3,17,23,11);;
gap> pocket_cube_U := (1,2,3,4)(5,17,13,9)(6,18,14,10);;
gap> pocket_cube_L := (5,6,7,8)(1,9,21,19)(4,12,24,18);;
gap> pocket_cube_D := (21,22,23,24)(12,16,20,8)(11,15,19,7);;
gap> pocket_cube_B := (17,18,19,20)(1,8,23,14)(2,5,24,15);;
gap> pocket_cube_gens := [pocket_cube_U, pocket_cube_L, pocket_cube_F, pocket_cube_R, pocket_cube_B, pocket_cube_D];;
gap> pocket_cube_gen_names := ["U","L","F","R","B","D"];;
gap> pocket_cube := GroupByGenerators(pocket_cube_gens);
<permutation group with 6 generators>
gap> scrambled := (1,19,20,3,18,24,15,10,5,8,23,13)(2,6,7,17,4,12,14,9,21);;
gap> inverse := Inverse(scrambled);
(1,13,23,8,5,10,15,24,18,3,20,19)(2,21,9,14,12,4,17,7,6)
gap> epi := EpimorphismFromFreeGroup(pocket_cube:names:=["U","L","F","R","B","D"]);;
gap> sequence := PreImagesRepresentative(epi,inverse);
B^-1*R*F*L^-1*B^-1*L*U^-1*L*F^-1*L^-2*U*L*U^-1*F^-1*L*U*L*U^-1*F*L^-1*U^-1*F^-\
1*U*F*U^-2*R*U*R^-1*U
gap> Length(sequence);
31
gap> #creating a subgroup chain from the chief series
gap> subgroupchain := ShallowCopy(ChiefSeries(pocket_cube));;
gap> Remove(subgroupchain,2);;
gap> #getting the hierarchical components
gap> cags := CosetActionGroups(subgroupchain);;
gap> StructureDescription(cags.components[1]);
"S8"
gap> StructureDescription(cags.components[2]);
"C3 x C3 x C3 x C3 x C3 x C3 x C3"
gap> #solving the cube from a random state
gap> scrambled := (1,10,12,6,23,14,16,24)(2,22,19,5,3,21,4,15)(7,9,20,17,11,8,18,13);;
gap> coordinates := Perm2Coords(scrambled, cags.transversals);
[ 22578, 552 ]
gap> levelkillers := LevelKillers(coordinates,cags.transversals);
[ (1,19,22,2,15,9,7,3)(4,21,10,18,24,16,14,23)(5,8,11,17,20,6,12,13), 
  (1,5,18)(3,13,10)(4,6,9)(8,19,24) ]
gap> halfsolved := scrambled * levelkillers[1];
(1,18,5)(3,10,13)(4,9,6)(8,24,19)
gap> halfsolvedcoords := Perm2Coords(halfsolved,cags.transversals);
[ 1, 552 ]
gap> halfsolved * levelkillers[2] = ();
true
gap> Stab2 := Stabilizer(pocket_cube,2);;
gap> StabF := Stabilizer(pocket_cube,[2,14,17], OnSets);;
gap> PC := FLCascadeGroup([pocket_cube, StabF, Stab2],2);
<cascade group with 6 generators, 2 levels with (8, 3) pts>
gap> TestFLAction([1..24], pocket_cube, PC);
true
gap> STOP_TEST( "Sgpdec package: fl.tst", 10000);
