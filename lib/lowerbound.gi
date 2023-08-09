#############################################################################
##
## lowerbound.gd           SgpDec package
##
## Copyright (C) 2023
##
## Thomas Gao, Chrystopher L. Nehaniv
##
## Checks essential dependency for Rhodes–Tilson complexity lower bound.
##

InstallGlobalFunction(IdempotentsForSubset,
function(sk, set)
  return Filtered(Idempotents(TransSgp(sk)),
                  e -> OnFiniteSet(BaseSet(sk), e) = set);
end);

InstallGlobalFunction(CheckEssentialDependency, function(sk, d1, d2)
  # d1 is lower than d2 so larger set
  local G1, CalX2, CalI2, skJ, x1, x2, e1, JGroup, S;
  S := TransSgp(sk);

  for x1 in Concatenation(SubductionClassesOnDepth(sk, d1)) do
    for x2 in Concatenation(SubductionClassesOnDepth(sk, d2)) do
      if IsSubsetBlist(x1, x2) then

        for e1 in IdempotentsForSubset(sk, x1) do
          G1 := SchutzenbergerGroup(HClass(S, e1));

          CalX2 := Enumerate(Orb(G1, x2, OnFiniteSet));

          #all idempotents with images that are members of CalX2;
          CalI2 := Concatenation(List(CalX2, Xt -> IdempotentsForSubset(sk, Xt)));

          if IsEmpty(CalI2) then
            continue;
          fi;
          
          skJ := Skeleton(Semigroup(CalI2));

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
