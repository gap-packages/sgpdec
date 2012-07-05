

##########################################################################
TestDependencyExtraction :=  function(cascprodinfo)
local i,rnd;
Print("Dependencies extracted from random operations, and checked whether they construct the same operation.\n");
for i in [1..ITER] do
  rnd := RandomCascadedOperation(cascprodinfo,13);
  if DefineCascadedOperation(cascprodinfo, DependencyMapsFromCascadedOperation(rnd)) <> rnd  then 
      Print("FAIL\n");Error("Dependency extraction malfunction!\n"); 
  elif CascadedOperation(cascprodinfo, DepFuncTableFromCascOp(rnd)) <> rnd then 
      Print("FAIL\n");Error("Dependency abstraction malfunction!\n"); 
  else
      Print("#\c");
  fi;
od;
Print("\nPASSED\n");
end;;
