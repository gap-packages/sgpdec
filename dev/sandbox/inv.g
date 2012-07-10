# transform the argument of the dependency and invert the value
InvCascadedOperationByDependencies := function(cascperm)
local invmaps, dep;    
 
  invmaps := [];
  for dep in DependencyMapsFromCascadedOperation(cascperm) do
    Add(invmaps,
        [List([1..Size(dep[1])], x-> dep[1][x]^(cascperm!.depfunc(dep[1]{[1..x-1]}))),
         Inverse(dep[2])
         ]);
  od;
  return CascadedOperation(CascadedStructureOf(cascperm), DependencyTable(invmaps));
end;