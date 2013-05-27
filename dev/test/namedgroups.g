#some predefined groups for convenience

################################################################################
# CYCLIC #######################################################################
################################################################################
Z2 := CyclicGroup(IsPermGroup,2);C2 := Z2;SetName(Z2,"Z2");
Z3 := CyclicGroup(IsPermGroup,3);C3 := Z3;SetName(Z3,"Z3");
Z4 := CyclicGroup(IsPermGroup,4);C4 := Z4;SetName(Z4,"Z4");
Z5 := CyclicGroup(IsPermGroup,5);C5 := Z5;SetName(Z5,"Z5");
Z6 := CyclicGroup(IsPermGroup,6);C6 := Z6;SetName(Z6,"Z6");
Z7 := CyclicGroup(IsPermGroup,7);C7 := Z7;SetName(Z7,"Z7");
Z8 := CyclicGroup(IsPermGroup,8);C8 := Z8;SetName(Z8,"Z8");
Z9 := CyclicGroup(IsPermGroup,9);C9 := Z9;SetName(Z9,"Z9");
Z10 := CyclicGroup(IsPermGroup,10);C10 := Z10;SetName(Z10,"Z10");
Z11 := CyclicGroup(IsPermGroup,11);C11 := Z11;SetName(Z11,"Z11");

################################################################################
# SYMMETRIC ####################################################################
################################################################################
S3 := SymmetricGroup(IsPermGroup,3);SetName(S3,"S3");
S4 := SymmetricGroup(IsPermGroup,4);SetName(S4,"S4");
S5 := SymmetricGroup(IsPermGroup,5);SetName(S5,"S5");
S6 := SymmetricGroup(IsPermGroup,6);SetName(S6,"S6");
S7 := SymmetricGroup(IsPermGroup,7);SetName(S7,"S7");
S8 := SymmetricGroup(IsPermGroup,8);SetName(S8,"S8");
S9 := SymmetricGroup(IsPermGroup,9);SetName(S9,"S9");
S10 := SymmetricGroup(IsPermGroup,10);SetName(S10,"S10");
S11 := SymmetricGroup(IsPermGroup,11);SetName(S11,"S11");

################################################################################
# ALTERNATING ##################################################################
################################################################################
A3 := AlternatingGroup(IsPermGroup,3);
A4 := AlternatingGroup(IsPermGroup,4);
A5 := AlternatingGroup(IsPermGroup,5);
A6 := AlternatingGroup(IsPermGroup,6);
A7 := AlternatingGroup(IsPermGroup,7);
A8 := AlternatingGroup(IsPermGroup,8);
A9 := AlternatingGroup(IsPermGroup,9);
A10 := AlternatingGroup(IsPermGroup,10);
A11 := AlternatingGroup(IsPermGroup,11);

################################################################################
# DIHEDRAL #####################################################################
################################################################################
D3 := DihedralGroup(IsPermGroup,2*3);SetName(D3,"D3");
D4 := DihedralGroup(IsPermGroup,2*4);SetName(D4,"D4");
D5 := DihedralGroup(IsPermGroup,2*5);SetName(D5,"D5");
D6 := DihedralGroup(IsPermGroup,2*6);SetName(D6,"D6");
D7 := DihedralGroup(IsPermGroup,2*7);SetName(D7,"D7");
D8 := DihedralGroup(IsPermGroup,2*8);SetName(D8,"D8");
D9 := DihedralGroup(IsPermGroup,2*9);SetName(D9,"D9");
D10 := DihedralGroup(IsPermGroup,2*10);SetName(D10,"D10");
D11 := DihedralGroup(IsPermGroup,2*11);SetName(D11,"D11");

# MATHIEU ######################################################################
M11 := Group([(1,2,3,4,5,6,7,8,9,10,11), (10,4,6,5) (7,3,8,11)]);

################################################################################
# RUBIK CUBES ##################################################################
################################################################################
#ULFRBD
PocketCube := Group((9,10,11,12)(4,13,22,7)(3,16,21,6),
                    (13,14,15,16)(2,20,22,10)(3,17,23,11),
                    (1,2,3,4)(5,17,13,9)(6,18,14,10),
                    (5,6,7,8)(1,9,21,19)(4,12,24,18),
                    (21,22,23,24)(12,16,20,8)(11,15,19,7),
                    (17,18,19,20)(1,8,23,14)(2,5,24,15));

RubiksCube := Group(
 ( 1, 3, 8, 6)( 2, 5, 7, 4)( 9,33,25,17)(10,34,26,18)(11,35,27,19),
 ( 9,11,16,14)(10,13,15,12)( 1,17,41,40)( 4,20,44,37)( 6,22,46,35),
 (17,19,24,22)(18,21,23,20)( 6,25,43,16)( 7,28,42,13)( 8,30,41,11),
 (25,27,32,30)(26,29,31,28)( 3,38,43,19)( 5,36,45,21)( 8,33,48,24),
 (33,35,40,38)(34,37,39,36)( 3, 9,46,32)( 2,12,47,29)( 1,14,48,27),
 (41,43,48,46)(42,45,47,44)(14,22,30,38)(15,23,31,39)(16,24,32,40) );