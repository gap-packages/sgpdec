#mapping group elements bijectively to an index integer
#based on the positions in the ordered list of the elements
Elts2Points := function(G)
local l,n;
  l := AsSortedList(G);
  n := Size(l);
  return MappingByFunction(G, Domain([1..n]), g->Position(l,g));
end;

#isomorphism from G to its regular representation
RegIsom := function(G)
  local l,n,Ggens, Rgens;
  l :=  AsSortedList(G);
  n := Size(l);
  Ggens := GeneratorsOfGroup(G);
  Rgens := List(Ggens, g -> AsPermutation(TransformationOp(g,l,OnLeftInverse)));
  return GroupHomomorphismByImages(G, Group(Rgens),Ggens,Rgens);
end;

Reg := function(G) return Range(RegIsom(G)); end;

#elements of the regular representation coded as integers
Reg2Points := function(G)
  return CompositionMapping(Elts2Points(G),
                 InverseGeneralMapping(RegIsom(G)));
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

SDActionCoords := function(x1,x2,rG2p, rN2p, rphi)
  local acts;
  acts := SDComponentActions(x1,x2,rG2p, rN2p, rphi);
  acts[1] := Image(rG2p,PreImage(rG2p,x1[1])*acts[1]);
  acts[2] := Image(rN2p,PreImage(rN2p,x1[2])*acts[2]);
  return acts;
end;

SDFlatAction := function(t,rG2p, rN2p, rphi, dom)
local i, nstate, state,fla;
  fla := [];
  for i in [1..Size(dom)]  do
    nstate  := SDActionCoords(dom[i],t,rG2p,rN2p, rphi);
    Add(fla, Position(dom,nstate));
  od;
  return fla;
end;

SemidirectElementDepFuncT := function(t,rG2p, rN2p, rphi, dom)
local j,actions,dependencies,arg, state;

  #the lookup for the new dependencies
  dependencies := [];
  #we go through all states
  for state in dom  do
    actions := SDComponentActions(state,t,rG2p,rN2p, rphi);
    #examine whether there is a nontrivial action, then add
    for j in [1..Length(actions)] do
      if not IsOne(actions[j]) then
        arg := state{[1..(j-1)]};
        AddSet(dependencies, [arg, actions[j]]);
      fi;
    od;
  od;
  return dependencies;
end;

#converting a group automorphism to a the corresponding
#automorphism on the regular representation
RegularizeAutomorphism := function(aut,reghom)
  return CompositionMapping(reghom,
                 CompositionMapping(aut, InverseGeneralMapping(reghom)));
end;

# G top level group
# phi: G -> Aut(N)
# N bottom level group
SemidirectCascade := function(G,phi,N)
  local rG,
        rN,
        dom,
        comps,
        l,rphi,i,autgens,gens,genGcoords,genHcoords,rGhom,rNhom,rG2p,rN2p;
  rGhom := RegIsom(G);
  rNhom := RegIsom(N);
  rG := Range(rGhom);
  rN := Range(rNhom);
  comps := [rG,rN];
  dom := EnumeratorOfCartesianProduct(ComponentDomains(comps));
  l := [];
  #get the generator sets
  gens := GeneratorsOfGroup(G);
  autgens := List(gens,g -> Image(phi,g));
  #make both sets regular
  gens := List(gens, g -> Image(rGhom,g));
  autgens := List(autgens, a -> RegularizeAutomorphism(a,rNhom));
  rphi := GroupHomomorphismByImages(
                  rG,
                  Group(autgens),
                  gens,
                  autgens);
  rG2p := Reg2Points(G);
  rN2p := Reg2Points(N);
  genGcoords := List(GeneratorsOfGroup(rG), g->[Image(rG2p,g),Image(rN2p,())]);
  genHcoords := List(GeneratorsOfGroup(rN), h->[Image(rG2p,()),Image(rN2p,h)]);
  for i in Concatenation(genGcoords,genHcoords) do
    Add(l,SemidirectElementDepFuncT(i,
            rG2p,
            rN2p,
            rphi,
            dom));
  od;
  return  List(l, x -> CascadeNC([rG,rN], x));
end;

CheckAllSemidirectProducts := function(G,N)
  local l,A,hom, gens, P1, P2;
  l := [];
  A := AutomorphismGroup(N);
  for hom in AllHomomorphismClasses(G,A) do
    P1 := SemidirectProduct(G,hom,N);
    Print(StructureDescription(P1),"#", Order(P1), " = \c");
    gens := List(SemidirectCascade(G,hom,N),
                 x->AsPermutation(AsTransformation(x)));
    P2 := Group(gens);
    Print(StructureDescription(P2),"#", Order(P2)," \c");
    #if IdSmallGroup(P1) <> IdSmallGroup(P2) then
    if IsomorphismGroups(P1, P2) = fail then
      Print("***FAIL***\n");
    else
      Print("\n");
    fi;
  od;
end;

###UTIL#########################################################################
#print general mappings on the screen
PrintMappings := function(genmap)
  Perform(Source(genmap), function(x)Print(x,"->",Image(genmap,x),"\n") ;end);
end;
