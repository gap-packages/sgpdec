Read("demo.g");

#LogTo("biglog");

VERBOSE := false;

bigfunc := function(G)
local ld;
Print("Testing group: " , StructureDescription(G));
  ld := LagrangeDecomposition(G);
  comprehenisiveCoordCalcCheck(ld);  
  ld := LagrangeDecomposition(G,CompositionSeries);
  comprehenisiveCoordCalcCheck(ld);  
  Print(" OK\n");
end;

ApplyToSmallPermGroups([2..510],bigfunc);
