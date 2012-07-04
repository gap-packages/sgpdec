#returns true if the core of U in G is the trivial group
IsCoreFree := function(G,U)
  return IsTrivial(Core(G,U));
end;


findPossibleIsomorphicCosetActions:= function(G)
local subgroups, subgroup, corefrees, numofpoints;
  numofpoints := FiniteSetWithSizeOfUniverse([], Order(G));
  subgroups := List(ConjugacyClassesSubgroups(G), x->Representative(x));
  corefrees := [];
  for subgroup in subgroups do
    if IsCoreFree(G,subgroup) then Add(numofpoints,Order(G) / Order(subgroup));fi;        
  od;
  return numofpoints;
end;
