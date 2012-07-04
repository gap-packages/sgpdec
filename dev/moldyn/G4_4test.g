Read("slowmolhists.g");
Read("../uldg/uldg.g");

gens := TransformationsFromElementaryCollapsings(GammaGraph(4,4),4);;
for i in [1..33] do 
  howmany_permutations(gens,FiniteSet([1,2,3]),i);
od;
