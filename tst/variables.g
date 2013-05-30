# just a few groups and semigroups to play with
Z2 := CyclicGroup(IsPermGroup,2);
Z3 := CyclicGroup(IsPermGroup,3);
Z5 := CyclicGroup(IsPermGroup,5);
S4 := SymmetricGroup(IsPermGroup,4);
S5 := SymmetricGroup(IsPermGroup,5);
S6 := SymmetricGroup(IsPermGroup,6);
S7 := SymmetricGroup(IsPermGroup,7);
S8 := SymmetricGroup(IsPermGroup,8);
D5 := DihedralGroup(IsPermGroup,2*5);
D8 := DihedralGroup(IsPermGroup,2*8);

T3 := FullTransformationSemigroup(3);
FF := SemigroupByGenerators([Transformation([1,1]),Transformation([2,2]),
              Transformation([1,2])]);
