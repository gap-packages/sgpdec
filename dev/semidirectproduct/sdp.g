#mapping group elements bijectively to an index integer
#based on the positions in the ordered list of the elements
Elts2Points := function(G)
local l,n;
  l := AsSortedList(G);
  n := Size(l);
  return MappingByFunction(G, Domain([1..n]), g->Position(l,g));
end;

#isomorphism from G to its regular representation
RegHom := function(G)
  local l,n,Ggens, Rgens;
  l :=  AsSortedList(G);
  n := Size(l);
  Ggens := GeneratorsOfGroup(G);
  Rgens := List(Ggens, g -> PermList(ActionOn(l,g,OnRight)));
  return GroupHomomorphismByImages(G, Group(Rgens),Ggens,Rgens);
end;

#elements of the regular representation coded as integers
Reg2Points := function(G)
  return CompositionMapping(Elts2Points(G),
                 InverseGeneralMapping(RegHom(G)));
end;

ActionIsom := function(G)
  local stabrt,f,invf;
  stabrt := RightTransversal(G,Stabilizer(G,1));
  f := function(g) return  PositionCanonical(stabrt,g);end;
  invf := function(p) return stabrt[p];end;
  return [MappingByFunction(G, Domain(MovedPoints(G)),f,invf),
          MappingByFunction(Domain(MovedPoints(G)),G,invf)];
end;

SDCompActs := function(x1,x2,G2p,p2G, N2p,p2N, phi)
  local ca, g1,g2,n2,theta;
  ca := [];
  g1 := Image(p2G, x1[1]);
  g2 := Image(p2G, x2[1]);
  #top level action
  ca[1] := g2;
  #n1 does not matter
  n2 := Image(p2N, x2[2]);
  theta := Image(phi, g1);
  #bottom level action
  ca[2] := Image(theta, n2);
  return ca;
end;

SDComponentActions := function(x1,x2,rG2p, rN2p, rphi)
  local ca, h1,h2,n2,theta;
  ca := [];
  h1 := PreImage(rG2p, x1[1]);
  h2 := PreImage(rG2p, x2[1]);
  #top level action
  ca[1] := h2;
  #n1 does not matter
  n2 := PreImage(rN2p, x2[2]);
  theta := Image(rphi, h1);
  #bottom level action
  ca[2] := Image(theta, n2);
  return ca;
end;

SemidirectElementDepFuncT := function(t,rG2p, rN2p, rphi, csh)
local j,states, actions,depfunctable,arg, state;

  #the states
  states := AllCoords(csh);
  #the lookup for the new dependencies
  depfunctable := [];
  #we go through all states
  for state in states  do
    actions := SDComponentActions(state,t,rG2p,rN2p, rphi);
    #examine whether there is a nontrivial action, then add
    for j in [1..Length(actions)] do
      if not IsOne(actions[j]) then
        arg := state{[1..(j-1)]};
        RegisterNewDependency(depfunctable, arg, actions[j]);
      fi;
    od;
  od;
  return depfunctable;
end;

RegularizeAutomorphism := function(aut)
  local G,rh;
  G := Source(aut);
  rh := RegHom(G);
  return CompositionMapping(rh,
                 CompositionMapping(aut, InverseGeneralMapping(rh)));
end;

# G top level group
# phi: G -> Aut(N)
# N bottom level group
SemidirectCascade := function(G,phi,N)
  local rG,
        rN,
        csh,l,rphi,tmp,i,autgens,gens,genGcoords, genHcoords,rGhom, rNhom;
  rGhom := RegHom(G);
  rNhom := RegHom(N);
  rG := Range(rGhom);
  rN := Range(rNhom);
  csh := CascadeShell([rG,rN]);
  l := [];
  tmp := CompositionMapping(phi,InverseGeneralMapping(rGhom));
  #get the generator of the automorphism group
  gens := GeneratorsOfGroup(Source(phi));
  autgens := List(gens,g -> RegularizeAutomorphism(Image(phi,g)));
  rphi := GroupHomomorphismByImages(
                  Source(tmp),
                  Group(autgens),
                  GeneratorsOfGroup(Source(tmp)),
                  autgens);
  genGcoords := List(GeneratorsOfGroup(rG), g -> [Image(Reg2Points(G),g),1]);
  genHcoords := List(GeneratorsOfGroup(rN), h -> [1,Image(Reg2Points(N),h)]);
  for i in Concatenation(genGcoords,genHcoords) do
  #for i in AllCoords(csh) do #gencoords do
    Add(l,SemidirectElementDepFuncT(i,
            Reg2Points(rG),
            Reg2Points(rN),
            rphi,
            csh));
  od;
  return  List(l, x -> CascadedTransformation(csh, x));
end;

CheckAllSemidirectProducts := function(G,N)
  local l,A,hom, gens, P1, P2;
  l := [];
  A := AutomorphismGroup(N);
  for hom in AllHomomorphismClasses(G,A) do
    P1 := SemidirectProduct(G,hom,N);
    Print(StructureDescription(P1),"#", Order(P1), " - ");
    gens := List(SemidirectCascade(G,hom,N),x->AsPermutation(x));
    P2 := Group(gens);
    Print(StructureDescription(P2),"#", Order(P2), IdSmallGroup(P2)," ");
    if IdSmallGroup(P1) = IdSmallGroup(P2) then
      Print("OK\n");
    else
      Print("FAIL\n");
      PrintMappings(hom);
    fi;
  od;
end;

###UTIL#########################################################################
#print general mappings on the screen
PrintMappings := function(genmap)
  Perform(Source(genmap), function(x)Print(x,"->",Image(genmap,x),"\n") ;end);
end;
