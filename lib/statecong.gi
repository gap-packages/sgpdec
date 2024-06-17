################################################################################
##  SgpDec                            	             Congruences on state sets
##  Copyright (C) 2024                                  Attila Egri-Nagy et.al
################################################################################
### creating congruences on X for (X,S) for a surjective homomorphism
# the algorithm is similar to the classical DFA minimization
# TODO: GAP library has Partition although it is undocumented - check whether it is usable here or not

#gives a lookup for a point to the class it belongs to
ReverseLookup := function(partition)
  return HashMap(Concatenation(List(partition,
                                    eqcl -> List(eqcl,
                                                 x -> [x, eqcl]))));
end;
MakeReadOnlyGlobal("ReverseLookup");

# Gives classes to be merged if needed, if everything checks, then it returns
# the empty list. Going through all classes and generators gens, but immediately
# returning the first found classes to be merged.
# eqcls - the equivalence classes so far
# lookup takes a point to its current equivalence class
ClassesToBeMerged := function(eqcls, gens)
  local g, eqcl, result, lookup;
  lookup := ReverseLookup(eqcls);
  for g in gens do
    for eqcl in eqcls do
      result := AsSet(List(eqcl, x -> lookup[OnPoints(x,g)]));
      if Size(result) > 1 then #some points in eqcl went to different classes
        return result;
      fi;
    od;
  od;
  return []; #all checks, nothing to merge
end;
MakeReadOnlyGlobal("ClassesToBeMerged");

# given a partition and classes to be merged, it returns a new partiton
# with merged classes
# removes the ones to be merged and adds their union
# Both Difference and Union return new lists, thus the partition is new.
# DANGER we assume the classes are ordered, but Union silently applies Set
MergeClasses := function(partition, tomerge)
  return Concatenation(Difference(partition, tomerge),
                       [Union(tomerge)]);
end;
MakeReadOnlyGlobal("MergeClasses");

# completes a set of disjoint sets into a partition of [1..n]
# by adding singleton sets for the missing states
CompletePartition := function(disjoint_sets, n)
  return Set(Concatenation(disjoint_sets,
                           List(Difference([1..n], Union(disjoint_sets)),
                                x->[x])));
end;
MakeReadOnlyGlobal("CompletePartition");

### THE MAIN FUNCTION TO CALL
# Returns the coarsest congruence, in which the given seed sets are inside
# equivalence classes.
# seeds: disjoint sets of states
# gens: transformations, typically generators of the ts
InstallGlobalFunction(StateSetCongruence,
function(gens, seeds)
  local n, partition, collapsible;
  n := DegreeOfTransformationCollection(gens);
  partition := CompletePartition(seeds,n);
  repeat
    collapsible := ClassesToBeMerged(partition, gens);
    if not(IsEmpty(collapsible)) then
      partition := MergeClasses(partition, collapsible);
    fi;
  until IsEmpty(collapsible);
  #to guarantee that it is sorted
  return AsSortedList(List(partition, eqcl -> AsSortedList(eqcl)));
end);

