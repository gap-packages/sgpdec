## Dot Natural subsystem code - Modified to store permutation group information without dot and symbols
result := [];  # Store permutation group information

InstallGlobalFunction(GetPermutationGroups, function(arg)
  local sk, params, states, dx, x1, px1, hx1, PermGenWord, PermutatorGeneratorWords, w, W, permutationGroup;

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

  for dx in [1..DepthOfSkeleton(sk)-1] do
    for x1 in RepresentativeSetsOnDepth(sk, dx) do
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
          states := x1,
          permutatorWords := PermutatorGeneratorWords
        );

        Add(result, permutationGroup);
      fi;
    od;
  od;

  return result;
end);
