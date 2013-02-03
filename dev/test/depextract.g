TestDependencyExtraction :=  function(csh)
local i,rnd;
  Print("Dependencies extracted from random operations, ");
  Print("and checked whether they construct the same operation.\n");
  for i in [1..ITER] do
    rnd := RandomCascadedTransformation(csh,13);
    if rnd <> CascadedTransformation(csh,
            DependencyTable(DependencyMapsFromCascadedTransformation(rnd))) then
      Print("FAIL\n");Error("Dependency extraction malfunction!\n");
# abstracting of depfunctions moved back to dev, so the next check is disabled
#  elif CascadedTransformation(csh, DepFuncTableFromCascOp(rnd)) <> rnd then
#      Print("FAIL\n");Error("Dependency abstraction malfunction!\n");
    else
      Print("#\c");
    fi;
  od;
  Print("\nPASSED\n");
end;;