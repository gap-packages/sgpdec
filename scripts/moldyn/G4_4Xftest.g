Read("slowmolhists.g");
Read("../uldg/uldg.g");

gens := TransformationsFromElementaryCollapsings(GammaGraph(4,4),4);;
Remove(gens); #removing last
for i in [1..33] do 
  howmany_nonfallers(gens,FiniteSet([1,2,3]),i);
od;
