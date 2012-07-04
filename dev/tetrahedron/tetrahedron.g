#flip
f := (1,2)(3,4);
#rotation
r := (1,2,3);

gens := [r,f];
symbols := ["r","f"];

tetrahedron := Group(gens);

tetracoords := LagrangeDecomposition(tetrahedron);


tf := Transformation([2,1,4,3]);
tr := Transformation([2,3,1,4]);
tc := Transformation([1,2,3,3]);

tgens := [tf,tr,tc];
tsg := Semigroup(tgens);
hd := HolonomyDecomposition(tsg);
