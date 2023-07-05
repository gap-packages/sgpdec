## Dot Natural subsystem code - Modified to store permutation group information without dot and symbols
result := [];  # Store permutation group information

InstallGlobalFunction(GetPermutationGroups, function(arg)
  local sk, params, states, dx, cls, x1, px1, hx1, PermGenWord, PermutatorGeneratorWords, w, W, permutationGroup;

  # Getting local variables for the arguments
  sk := arg[1];
  if IsBound(arg[2]) then
    params := arg[2];
  else
    params := rec();
  fi;

  # Setting the state names
  if "states" in RecNames(params) then
    states := params.states;
  else
    states := List([1..DegreeOfSkeleton(sk)], String);
  fi;

  SgpDecFiniteSetDisplayOn();

  for dx in [1..DepthOfSkeleton(sk)-1] do
    for cls in SubductionClassesOnDepth(sk, dx) do
      for x1 in cls do
        px1 := PermutatorGroup(sk, x1);
        hx1 := HolonomyGroup@SgpDec(sk, x1);

        if not IsTrivial(px1) then
          PermutatorGeneratorWords := [];
          W := NontrivialRoundTripWords(sk, x1);

          for w in W do
            PermGenWord := Concatenation(List(w, x -> String(x)));
            Add(PermutatorGeneratorWords, PermGenWord);
          od;

          # Store the permutation group information as a tuple
          permutationGroup := rec(
            depth := dx,
            states := x1,
            permutatorWords := PermutatorGeneratorWords
          );

          Add(result, permutationGroup);
        fi;
      od;
    od;
  od;

  return result;
end);

InstallGlobalFunction(IdempotentsForSubset,
function(sk,set)
local roundtrips,rtws,ids;
  if not ContainsSet(sk,set) then return fail;fi;
  rtws := RoundTripWords(sk,set);
  roundtrips := List(rtws, w->EvalWordInSkeleton(sk,w));
  ids := Filtered([1..Size(roundtrips)],
                      x-> IsIdentityOnFiniteSet(roundtrips[x],set));
  Info(SkeletonInfoClass, 2, "identity roundtrips/all roundtrips: ",
       Size(rtws), "/", Size(ids));
  return rtws{ids};
end);

# InstallGlobalFunction(Test, function(arg)
#   S := arg[1];
  
# end);

InstallGlobalFunction(GetSubgroupIdempotents, function(arg)
  local sk, params, states, dx, cls, x1, px1, hx1, IDs, subgIds, w, W, IdempotentSet;

  # Getting local variables for the arguments
  sk := arg[1];
  if IsBound(arg[2]) then
    params := arg[2];
  else
    params := rec();
  fi;

  # Setting the state names
  if "states" in RecNames(params) then
    states := params.states;
  else
    states := List([1..DegreeOfSkeleton(sk)], String);
  fi;

  SgpDecFiniteSetDisplayOn();

  for dx in [1..DepthOfSkeleton(sk)-1] do
    for cls in SubductionClassesOnDepth(sk, dx) do
      for x1 in cls do # TODO: duplicates of sets???
        px1 := PermutatorGroup(sk, x1);
        hx1 := HolonomyGroup@SgpDec(sk, x1);

        if not IsTrivial(px1) then
          IdempotentSet := [];
          W := IdempotentsForSubset(sk, x1);

          for w in W do
            IDs := EvalWordInSkeleton(sk, w);#Concatenation(List(w, x -> String(x)));
            Add(IdempotentSet, IDs);
          od;

          # Store the permutation group information as a tuple
          subgIds := rec(
            depth := dx,
            states := x1,
            idempotents := Set(IdempotentSet)
          );

          Add(result, subgIds);
        fi;
      od;
    od;
  od;

  return Set(result);
end);
