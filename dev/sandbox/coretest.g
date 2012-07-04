#just checking whether making Gi faithful is really modding out by the core
coreTest := function(G, series)
local i,ld,c,coremod;
  ld := LagrangeDecomposition(G,series);;
  #Perform(ld, StructureDescription);         
  Print("\n");
  for c in ld do Display(StructureDescription(c));od;
  Print("\n");
  for i in [1..Length(series) - 1] do 
    coremod := FactorGroup(series[i],Core(series[i],series[i+1]));
    Display(StructureDescription(coremod));
    if IsomorphismGroups(ld[i],coremod) = fail then Print("!!!!!!!!!!!!!FAIL!!");fi;
  od;
end;
