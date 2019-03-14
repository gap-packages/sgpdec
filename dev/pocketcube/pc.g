#ULFRBD
PocketCube := Group((9,10,11,12)(4,13,22,7)(3,16,21,6),
                    (13,14,15,16)(2,20,22,10)(3,17,23,11),
                    (1,2,3,4)(5,17,13,9)(6,18,14,10),
                    (5,6,7,8)(1,9,21,19)(4,12,24,18),
                    (21,22,23,24)(12,16,20,8)(11,15,19,7),
                    (17,18,19,20)(1,8,23,14)(2,5,24,15));

#trying a series of shallow decompositions

StabCorner1 := Stabilizer(PocketCube, [1,5,18],OnSets);
Stab1 := Stabilizer(StabCorner1, 1);
FL1 := FLCascadeGroup([PocketCube, StabCorner1,Stab1],1);
TestFLAction([1..24],PocketCube,FL1);

StabCorner2 := Stabilizer(Stab1, [2,14,17],OnSets);
Stab2 := Stabilizer(StabCorner2, 2);
FL2 := FLCascadeGroup([Stab1, StabCorner2,Stab2],2);
#TestFLAction(Difference([1..24],[1,5,18]),Stab1,FL2);
TestFLAction(ValidPoints(FL2),Stab1,FL2);

StabCorner3 := Stabilizer(Stab2, [3,10,13],OnSets);
Stab3 := Stabilizer(StabCorner3, 3);
FL3 := FLCascadeGroup([Stab2, StabCorner3,Stab3],3);
TestFLAction(ValidPoints(FL3),Stab2,FL3);

StabCorner4 := Stabilizer(Stab3, [4,6,9],OnSets);
Stab4 := Stabilizer(StabCorner4, 4);
FL4 := FLCascadeGroup([Stab3, StabCorner4,Stab4],4);
TestFLAction(ValidPoints(FL4),Stab3,FL4);

StabCorner7 := Stabilizer(Stab4, [7,12,21],OnSets);
Stab7 := Stabilizer(StabCorner7, 7);
FL5 := FLCascadeGroup([Stab4, StabCorner7,Stab7],7);
TestFLAction(ValidPoints(FL5),Stab4,FL5);

StabCorner8 := Stabilizer(Stab7, [8,19,24],OnSets);
Stab8 := Stabilizer(StabCorner8, 8);
FL6 := FLCascadeGroup([Stab7, StabCorner8,Stab8],8);
TestFLAction(ValidPoints(FL6),Stab7,FL6);

StabCorner11 := Stabilizer(Stab8, [11,16,22],OnSets);
Stab11 := Stabilizer(StabCorner11, 11);
FL7 := FLCascadeGroup([Stab8, StabCorner11,Stab11],11);
TestFLAction(ValidPoints(FL7),Stab8,FL7);
