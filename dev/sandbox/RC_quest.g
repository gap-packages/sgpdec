orbits := Orbits(rubik_cube);

ahom1 := ActionHomomorphism(rubik_cube, orbits[1]);
G1 := Image(ahom1); # pocket cube
K1 := Kernel(ahom1); # middle cube without top

ahom2 := ActionHomomorphism(rubik_cube, orbits[2]);
G2 := Image(ahom2); # middle cube
K2 := Kernel(ahom2); #pocketcube without the top

R2 := Group( Union(GeneratorsOfGroup(K1), GeneratorsOfGroup(K2))); #direct product of K1, K2

PC_face := Stabilizer(K2,1);
MC_face := Stabilizer(K1,2);

PC_corner :=Stabilizer(K2,[1,9,35],OnSets);
MC_edge := Stabilizer(K1,[2,34],OnSets);


R3 := Group( Union(GeneratorsOfGroup(PC_corner), GeneratorsOfGroup(MC_edge)));


R4 := Group( Union(GeneratorsOfGroup(PC_face), GeneratorsOfGroup(MC_face))); 

series := [rubik_cube, R2, R3, R4];

ld := LagrangeDecomposition(rubik_cube,  series);

StructureDescription(ld[1]);
StructureDescription(ld[2]);
StructureDescription(ld[3]);

