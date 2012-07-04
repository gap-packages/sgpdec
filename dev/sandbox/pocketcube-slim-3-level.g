
G := pocket_cube;

alt := Intersection(G,AlternatingGroup(24));

# stabilizer of a face
sf := Stabilizer(G,1);
sfa := Intersection(sf,alt);

# stabilizer of a corner containing that face
sc := Stabilizer(G,[1,5,18],OnSets);
sca := Intersection(sc,alt);

# series down to stabilizer of face
ser := [G,alt,sca,sfa];

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
 

cascgens := [r1,r2,r3,r4,r5,r6];

flatgens := List(cascgens, x -> Flatten(ld,x));

G_ := Group(flatgens);

G__ := RemoveDuplicatePermGroupGenerators(G_);

Display(Order(G__));

Display(Length(GeneratorsOfGroup(G__))) ;


