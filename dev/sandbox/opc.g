opcsymbols := ["5>7",
"7>5",
"7>8",
"8>7",
"alpha",
"alpha-",
"beta",
"beta-",
"gamma",
"gamma-"];

opc := [Transformation([1,2,12,4,5,6,7,8,10,10,11,12,13,14,15,16,17]),
Transformation([2,2,3,4,5,6,7,8,9,10,11,12,13,15,15,16,17]),
Transformation([12,3,3,4,6,6,7,8,9,10,11,12,13,14,15,16,17]),
Transformation([1,2,3,4,5,6,7,8,9,11,11,12,14,14,15,16,16]),
Transformation([1,2,3,4,5,7,7,8,9,10,11,12,13,14,15,16,17]),
Transformation([1,2,3,4,5,6,7,8,9,10,12,12,13,14,15,16,17]),
Transformation([1,2,3,5,5,6,7,8,9,10,11,12,13,1,2,16,17]),
Transformation([1,2,3,4,5,6,8,8,9,10,11,13,13,14,15,16,17]),
Transformation([1,2,4,4,5,6,7,8,9,10,11,12,13,14,15,14,17]),
Transformation([1,2,3,4,5,6,7,9,9,10,11,12,17,14,15,16,17])];

OPC := Semigroup(opc);
SetInfoLevel(SkeletonInfoClass,2);
SetInfoLevel(HolonomyInfoClass,2);

hd := HolonomyDecomposition(OPC);

SaveWorkspace("opc.ws");
