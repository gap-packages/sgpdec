Read("dca.g");

A4_gens := [(1,2,3), (1,2)(3,4)]; #rotate and flip
A4_3gens := [(1,2,3), (1,2,4), (2,3,4), (1,3,4)]; #rotating around all vertices

 ld_chief := LagrangeDecomposition(Group(A4_gens));

chiefcascaded_A4_gens := List(A4_gens, x -> Raise(ld_chief,x));
chiefcascaded_A4_3gens := List(A4_3gens, x -> Raise(ld_chief,x));

 dca("chiefA4",chiefcascaded_A4_gens);
 dca("chiefA4_3",chiefcascaded_A4_3gens);


A4 := Group(A4_gens);
ld_stab := LagrangeDecomposition(A4,[A4,Stabilizer(A4,1),Group(())]);

stabcascaded_A4_gens := List(A4_gens, x -> Raise(ld_stab,x));
stabcascaded_A4_3gens := List(A4_3gens, x -> Raise(ld_stab,x));

 dca("stabA4",stabcascaded_A4_gens);
 dca("stabA4_3",stabcascaded_A4_3gens);
