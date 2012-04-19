#maximal subgroup in 2-level Z5 wreath which is 2-generated and 5-torsion
#these are the cascaded generators constructed from dependencies

#dependency maps
deps1 := [ [ [  ], (1,2,3,4,5) ] ];
deps2 := [ [ [ 1 ], (1,5,4,3,2) ], [ [ 2 ], (1,2,3,4,5) ] ];

#the cascaded structure
Z5Z5 := CascadeProductInfoStructure([Z5,Z5],[Z5States,Z5States],[Z5Ops,Z5Ops]);

#2 level 2generated 5 torsion 
gens_2l_2g_5t := [
    DefineCascadedOperation(Z5Z5,deps1),
    DefineCascadedOperation(Z5Z5,deps2)
];

