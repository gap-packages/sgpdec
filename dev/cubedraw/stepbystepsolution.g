gap> s2 := [pocket_cube];
[ <permutation group of size 88179840 with 6 generators> ]
gap> Add(s2, Stabilizer(s2[1], [1,5,18], OnSets));   
gap> Add(s2, Stabilizer(s2[2], 1));                 
gap> Add(s2, Stabilizer(s2[3], [1,2,3,4], OnSets));
gap> Add(s2, Stabilizer(s2[4], [1,2,3,4], OnTuples));
gap> Add(s2, Stabilizer(s2[5], [7,12,21], OnSets));   
gap> Add(s2, Stabilizer(s2[6], [7,12,21], OnTuples));
gap> s2;
[ <permutation group of size 88179840 with 6 generators>, <permutation group of size 11022480 with 13 generators>, <permutation group of size 3674160 with 12 generators>, <permutation group of size 3888 with 
    11 generators>, <permutation group of size 648 with 9 generators>, <permutation group of size 162 with 8 generators>, <permutation group of size 54 with 4 generators> ]
gap>  

