Read("moldyn.g");;

gens := TransformationsFromElementaryCollapsings(GammaGraph(6,4),6);;

driftingmoldyn(gens,[1000,1000,1000,1000,1000,1000],1000000,1000);

