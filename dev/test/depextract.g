TestDependencyExtraction :=  function(comps)
local i,rnd;
  Print("Dependencies extracted from random operations, ");
  Print("and checked whether they construct the same operation.\n");
  for i in [1..ITER] do
    rnd := RandomCascade(comps,13);
    if rnd <> CascadeNC(comps,DependenciesOfCascade(rnd)) then
      Print("FAIL\n");Error("Dependency extraction malfunction!\n");
    else
      Print("#\c");
    fi;
  od;
  Print("\nPASSED\n");
end;;
