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

#given a homomorphism, make it into homomorphism between regular representations
RegHomHom := function(hom)
  local G,H,rG,rH,rHhom;
  G := Source(hom);
  H := Range(hom);
  rHhom := RegHom(H);
  rG := Range(RegHom(G));
  rH := Range(rHhom);
  return GroupHomomorphismByImages(rG,rH, GeneratorsOfGroup(rG),
                 List(GeneratorsOfGroup(G), g->Image(rHhom,Image(hom,g))));
end;


Reg2Points := function(G)
  return CompositionMapping(Elts2Points(G),
                 InverseGeneralMapping(RegHom(G)));
end;

SDAction := function(x1,x2,rG2p, rN2p, rphi)
  local nx,h1,n1,h2,n2,theta;
  nx := [];
  h1 := PreImage(rG2p, x1[1]);
  h2 := PreImage(rG2p, x2[1]);
  nx[1] := h1 * h2;
  n1 := PreImage(rN2p, x1[2]);
  n2 := PreImage(rN2p, x2[2]);
  theta := Image(rphi, h1);
  nx[2] := n1 * Image(theta, n2);
  return nx;
end;

# G top level group
# phi: G -> Aut(N)
# N bottom level group
SemidirectCascade := function(G,phi,N)
  local rG,
        rN,
        csh;
  rG := Range(RegHom(G));
  rN := Range(RegHom(N));
  csh := CascadeShell([rG,rN]);
end;


AutZ3 := AutomorphismGroup(Z3);
Z2toAutZ3 := GroupHomomorphismByImages(Z2,A,[(1,2)], [AsList(AutZ3)[2]]);