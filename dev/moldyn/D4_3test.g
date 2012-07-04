Read("molhists.g");
Read("../uldg/uldg.g");

gens := TransformationsFromElementaryCollapsings(DeltaGraph(4,3),6);;

for l in [1..10] do #l - length of the words
  howmany_permutations(gens,FiniteSet([1,2,3]),l);
od;
