Elts2Points := function(G)
local l,n;
  l := AsList(G);
  n := Size(l);
  return MappingByFunction(Domain(l), Domain([1..n]), g->Position(l,g));
end;

PrintMappings := function(genmap)
  Perform(Source(genmap), function(x)Print(x,"->",Image(genmap,x),"\n") ;end);
end;

# G top level group
# phi: G -> Aut(N)
# N bottom level group
SemidirectCascade := function(G,phi,N)
local
  XtoG # [1..|G|] -> G
  ;
  #rGhom := RegularActionHomomorphism(G);
  #rNhom := RegularActionHomomorphism(N);
  #1st establish connection between the points and group elemnts
  X := AsSortedList(G);
  
end;