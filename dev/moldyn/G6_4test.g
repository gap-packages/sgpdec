Read("slowmolhists.g");
Read("../uldg/uldg.g");

gens := TransformationsFromElementaryCollapsings(GammaGraph(6,4),6);;
for i in [1..33] do 
  driftingmoldyn(gens,FiniteSet([1,2,3,4,5]),i);
od;
