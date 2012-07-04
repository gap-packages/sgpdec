Read("slowmolhists.g");
Read("../uldg/uldg.g");

gens := TransformationsFromElementaryCollapsings(GammaGraph(6,3),6);;
for i in [1..33] do 
  howmany_permutations(gens,FiniteSet([1,2,3,4,5]),i);
od;
