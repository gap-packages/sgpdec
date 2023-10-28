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

          if x2 in ExtendedImageSet(skJ) then
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

InstallGlobalFunction(MaxChainOfEssentialDependency, function(sk)
  # find all levels with groups
  local levels, level, i, j, groups, N, mem, links, newval, ChainOfLevels;

  levels := [];
  for level in [1..DepthOfSkeleton(sk)-1] do
    groups := GroupComponents(sk)[level];
    for i in [1..Length(groups)] do
      if not IsTrivial(groups[i]) then
        Add(levels, level);
        break;
      fi;
    od;
  od;

  N := Length(levels);

  if Length(levels) < 2 then
    return levels;
  fi;

  # run the chaining algorithm, equivalent to the following
  mem := List([1..N], i -> 1);
  links := List([1..N], i -> i);
  for i in List([2..N], i -> N+1-i) do # [N-1, ..., 1]
    for j in [i+1..N] do # [i+1, ..., N]
      if IsTrivial(CheckEssentialDependency(sk, levels[i], levels[j])) then
        continue;
      fi;

      newval := mem[j] + 1;
      if newval > mem[i] then
        mem[i] := newval;
        links[i] := j;
      fi;
    od;
  od;

  # find max in mem
  i := 1;
  for j in [2..N] do
    if mem[j] > mem[i] then
      i := j;
    fi;
  od;

  # find the longest chain
  ChainOfLevels := [];
  while i <> links[i] do
    Add(ChainOfLevels, levels[i]);
    i := links[i];
  od;
  Add(ChainOfLevels, levels[i]);

  return ChainOfLevels;
end);
