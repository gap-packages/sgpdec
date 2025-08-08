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

# EssentialDependencyGroup
InstallGlobalFunction(EssentialDependencyGroup, function(sk, x1, x2)
  local G1, CalX2, CalI2, skJ, e1, JGroup, S;
  S := TransSgp(sk);

  if IsSubsetBlist(x1, x2) then
    for e1 in IdempotentsForSubset(sk, x1) do
      G1 := SchutzenbergerGroup(HClass(S, e1));

      CalX2 := Enumerate(Orb(G1, x2, OnFiniteSet));

      # Get all idempotents with images that are members of CalX2;
      CalI2 := Concatenation(List(CalX2, Xt -> IdempotentsForSubset(sk, Xt)));

      if IsEmpty(CalI2) then
        continue;
      fi;
      
      skJ := Skeleton(Semigroup(CalI2));

      if x2 in ExtendedImageSet(skJ) then
        JGroup := PermutatorGroup(skJ, x2);

#  Test for Essential Dependency of J. Rhodes: 
        if IsSubgroup(JGroup,PermutatorGroup(sk, x2)) then 
          Assert( 1, PermutatorGroup(sk, x2) = JGroup, 
            Concatenation("PermutatorGroup(sk, x2) <> JGroup\nx2 = ", 
              TrueValuePositionsBlistString(x2), "\nx1 = ",
              TrueValuePositionsBlistString(x1), "\n") );
          return JGroup;
        fi;
      fi;
    od;
  fi;
  return Group(());
end);


InstallGlobalFunction(MaxChainOfEssentialDependency, function(sk)
  local o, Set2Index, Index2Set, maxChild, chainSizes, DFS, classesOnDepth,
      finalMax, idxFinalMax, pos;

  o := ForwardOrbit(sk);
  Set2Index := x -> Position(o,x);
  Index2Set := x -> o[x];

  maxChild := List(o, c -> -1); # Used for tracing the longest chain
  chainSizes := List(o, c -> -1);

  # Define the recursion function
  DFS := function(set_idx) # Input class is int
    local children, descendents, trivial, desc_idx, i, chainLengths, chainTemp, maxChainTemp;

    # Base Case: first check if the class is already in the list, return chain length if it is
    if chainSizes[set_idx] <> -1 then
      return chainSizes[set_idx];
    fi;

    # Use immediate child *sets* below a set with set_idx for more memory-efficient DFS
    children := Images(InclusionCoverRelation(sk), Index2Set(set_idx));
    children := Filtered(children, c -> SizeBlist(c) > 1);     # Remove singleton sets
    children := List(children, c -> Set2Index(c));

    # If the class has no nontrivial permutator group, return 0
    trivial := false;
    if IsTrivial(PermutatorGroup(sk, Index2Set(set_idx))) then
      chainSizes[set_idx] := 0;
      trivial := true;
    fi;

    # Base Case: if no children, return 1
    if IsEmpty(children) then
      if trivial then
        return 0;
      fi;
      chainSizes[set_idx] := 1;
      return 1;
    fi;

    # If there are children, find the chain length of each child
    List(children, c -> DFS(c)); # DFS first

    # If trivial, no need to check essential dependency
    if trivial then
      return 0;
    fi;

    # This gives all the set IDs? lower than and equal to itself
    descendents := Images(TransitiveClosureBinaryRelation(InclusionCoverRelation(sk)), Index2Set(set_idx));
    descendents := Filtered(descendents, d -> SizeBlist(d) > 1);     # Remove singleton sets
    descendents := List(descendents, d -> Set2Index(d));

    # If classes in descendent has essential dependency with the input class ID, 
    # add 1 to the chain length
    maxChainTemp := 1;
    for i in [1..Length(descendents)] do
      desc_idx := descendents[i];

      # Since all descendent classes have been searched, they all must have chain lengths <> -1.
      # Ignore descendent classes with trivial permutator groups
      if chainSizes[desc_idx] = 0 then
        continue;
      fi;

      # If there is an essential dependency, add 1 to the chain length
      if not IsTrivial(EssentialDependencyGroup(sk,
            Index2Set(set_idx),
            Index2Set(desc_idx))) then
        chainTemp := chainSizes[desc_idx] + 1;
        if chainTemp > maxChainTemp then
          maxChainTemp := chainTemp;
          maxChild[set_idx] := desc_idx;
        fi;
      fi;
    od;

    # Find the max chain length
    chainSizes[set_idx] := maxChainTemp;
    return chainSizes[set_idx];
  end;

  # Start the recursion
  List([1..Length(o)], i -> DFS(i));

  # Find the maximum chain length
  finalMax := Maximum(chainSizes);
  idxFinalMax := Position(chainSizes, finalMax);
  pos := idxFinalMax;

  # Trace the chain, and print the chain of subsets
  Print("Maximum Chain Found:");
  while maxChild[pos] <> -1 do
    Print(TrueValuePositionsBlistString(Index2Set(pos)), " -> ");
    pos := maxChild[pos];
  od;
  Print(TrueValuePositionsBlistString(Index2Set(pos)), "\n");

  return Maximum(chainSizes);
end);
