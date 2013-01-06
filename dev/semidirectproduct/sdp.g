Elts2Points := function(G)
local l,n;
  l := AsSortedList(G);
  n := Size(l);
  return MappingByFunction(G, Domain([1..n]), g->Position(l,g));
end;

PrintMappings := function(genmap)
  Perform(Source(genmap), function(x)Print(x,"->",Image(genmap,x),"\n") ;end);
end;

RegHom := function(G)
  local l,n,Ggens, Rgens;
  l :=  AsSortedList(G);
  n := Size(l);
  Ggens := GeneratorsOfGroup(G);
  Rgens := List(Ggens, g -> PermList(ActionOn(l,g,OnRight)));
  return GroupHomomorphismByImages(G, Group(Rgens),Ggens,Rgens);
end;

Reg2Points := function(G)
  return CompositionMapping(Elts2Points(G),
                 InverseGeneralMapping(RegHom(G)));
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