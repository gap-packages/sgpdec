#some groups

Z2 := CyclicGroup(IsPermGroup,2);
Z3 := CyclicGroup(IsPermGroup,3);
Z4 := CyclicGroup(IsPermGroup,4);C4 := Z4;
Z5 := CyclicGroup(IsPermGroup,5);C5 := Z5;

S3 := SymmetricGroup(IsPermGroup,3);
S4 := SymmetricGroup(IsPermGroup,4);
S5 := SymmetricGroup(IsPermGroup,5);

D8 := DihedralGroup(IsPermGroup,8);


###########################
########RUBIK CUBES########
###########################
pocket_cube_F := (9,10,11,12)(4,13,22,7)(3,16,21,6);
pocket_cube_R := (13,14,15,16)(2,20,22,10)(3,17,23,11);
pocket_cube_U := (1,2,3,4)(5,17,13,9)(6,18,14,10);
pocket_cube_L := (5,6,7,8)(1,9,21,19)(4,12,24,18);
pocket_cube_D := (21,22,23,24)(12,16,20,8)(11,15,19,7);
pocket_cube_B := (17,18,19,20)(1,8,23,14)(2,5,24,15);

pocket_cube_gens := [pocket_cube_U,
                    pocket_cube_L,
                    pocket_cube_F,
                    pocket_cube_R,
                    pocket_cube_B,
                    pocket_cube_D];

pocket_cube_gen_names := ["U","L","F","R","B","D"];


pocket_cube := GroupByGenerators(pocket_cube_gens);

rubik_cube := Group(
 ( 1, 3, 8, 6)( 2, 5, 7, 4)( 9,33,25,17)(10,34,26,18)(11,35,27,19),
 ( 9,11,16,14)(10,13,15,12)( 1,17,41,40)( 4,20,44,37)( 6,22,46,35),
 (17,19,24,22)(18,21,23,20)( 6,25,43,16)( 7,28,42,13)( 8,30,41,11),
 (25,27,32,30)(26,29,31,28)( 3,38,43,19)( 5,36,45,21)( 8,33,48,24),
 (33,35,40,38)(34,37,39,36)( 3, 9,46,32)( 2,12,47,29)( 1,14,48,27),
 (41,43,48,46)(42,45,47,44)(14,22,30,38)(15,23,31,39)(16,24,32,40) );

#Mathieu
M11 := Group([(1,2,3,4,5,6,7,8,9,10,11), (10,4,6,5) (7,3,8,11)]);
