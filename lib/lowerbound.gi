
InstallGlobalFunction(IdempotentsForSubset,
function(S, sk, set)
local e, IdempotentSet, ssize;
  ssize := Size(BaseSet(sk));
  IdempotentSet := [];
  for e in Idempotents(S) do
    # check whether the image of e is set
    if OnFiniteSet(BaseSet(sk), e) = set then
       Add(IdempotentSet, e);
    fi;
  od;
  return IdempotentSet;
end);

InstallGlobalFunction(CheckEssentialDependency, function(S, sk, d1, d2)
  # d1 is lower than d2 so larger set
  local G1, CalX2, CalI2, skJ, J, x1, x2, e1, Xt, JGroup;

  for x1 in Concatenation(SubductionClassesOnDepth(sk, d1)) do
    for x2 in Concatenation(SubductionClassesOnDepth(sk, d2)) do
      if IsSubsetBlist(x1, x2) then

        for e1 in IdempotentsForSubset(S, sk, x1) do
          G1 := SchutzenbergerGroup(HClass(S, e1));

          CalX2 := Enumerate(Orb(G1, x2, OnFiniteSet, rec(schreier := true, orbitgraph := true)));
          CalI2 := []; #Cal_I2 = all idempotents with images that are members of CalX2;
          for Xt in CalX2 do
            CalI2 := Concatenation(CalI2, IdempotentsForSubset(S, sk, Xt));
          od;

          if IsEmpty(CalI2) then
            continue;
          fi;
          
          J := Semigroup(CalI2);
          skJ := Skeleton(J);

          if ContainsSet( skJ, x2 ) then
            JGroup := PermutatorGroup(skJ, x2);

            if Size(JGroup) > 1 then # the stricter test is PermutatorGroup(sk, x2) = JGroup
              Assert( 1, PermutatorGroup(sk, x2) = JGroup, 
                Concatenation("PermutatorGroup(sk, x2) <> JGroup\nx2 = ", 
                  TrueValuePositionsBlistString(x2), "\nx1 = ",
                  TrueValuePositionsBlistString(x1), "\n") );
              return JGroup;
            fi;
          fi;
        od;

      fi;
    od;
  od;
  return Group(());
end);
