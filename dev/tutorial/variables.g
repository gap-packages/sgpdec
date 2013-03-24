# just a few groups and semigroups to play with
Z2 := CyclicGroup(IsPermGroup,2);
Z3 := CyclicGroup(IsPermGroup,3);
Z5 := CyclicGroup(IsPermGroup,5);
S4 := SymmetricGroup(IsPermGroup,4);

T3 := FullTransformationSemigroup(3);
FF := SemigroupByGenerators([Transformation([1,1]),Transformation([2,2]),
              Transformation([1,2])]);
