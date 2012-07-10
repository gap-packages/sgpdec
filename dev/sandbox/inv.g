InvCascadedOperationByCraft := function(cascperm)
local maps, invmaps, dep, arg, i;    
 
  maps := DependencyMapsFromCascadedOperation(cascperm);
  invmaps := [];
  for dep in maps do
      arg := ShallowCopy(dep[1]);
      for i in [1..Size(dep[1])] do
          arg[i] := arg[i]^Inverse( cascperm!.depfunc(arg{[1..i-1]}));
      od;     
      Add(invmaps, [arg, Inverse(dep[2])]);
  od;
  return CascadedOperation(CascadedStructureOf(cascperm), DependencyTable(invmaps));
end;