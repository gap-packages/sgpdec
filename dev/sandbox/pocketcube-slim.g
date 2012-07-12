
G := pocket_cube;

# stabilizer of a face
sf := Stabilizer(G,1);

# stabilizer of a corner containing that face
sc := Stabilizer(G,[1,5,18],OnSets);

# series down to stabilizer of face
ser := [G,sc,sf];

ld := LagrangeDecomposition(G, x-> ser);

gens := GeneratorsOfGroup(pocket_cube);

 r1 := Raise(ld,gens[1]);
 r2 := Raise(ld,gens[2]);
 r3 := Raise(ld,gens[3]);
 r4 := Raise(ld,gens[4]);
 r5 := Raise(ld,gens[5]);
 r6 := Raise(ld,gens[6]);
 
Display(r1);
Display(r2);
Display(r3);
Display(r4);
Display(r5);
Display(r6);


