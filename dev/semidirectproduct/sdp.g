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

SDComponentActions := function(x1,x2,rH2p, rN2p, rphi)
  local ca, h1,h2,n2,theta;
  ca := [];
  h1 := PreImage(rH2p, x1[1]);
  h2 := PreImage(rH2p, x2[1]);
  #top level action
  ca[1] := h2;
  #n1 does not matter
  n2 := PreImage(rN2p, x2[2]);
  theta := Image(rphi, h1);
  #bottom level action
  ca[2] := Image(theta, n2);
  return ca;
end;

SDActionCoords := function(x1,x2,rH2p, rN2p, rphi)
  local acts;
  acts := SDComponentActions(x1,x2,rH2p, rN2p, rphi);
  acts[1] := Image(rH2p,PreImage(rH2p,x1[1])*acts[1]);
  acts[2] := Image(rN2p,PreImage(rN2p,x1[2])*acts[2]);
  return acts;
end;

SDFlatAction := function(t,rH2p, rN2p, rphi, dom)
local i, nstate, state,fla;
  fla := [];
  for i in [1..Size(dom)]  do
    nstate  := SDActionCoords(dom[i],t,rH2p,rN2p, rphi);
    Add(fla, Position(dom,nstate));
  od;
  return fla;
end;

SemidirectElementDepFuncT := function(t,rH2p, rN2p, rphi, dom)
local j,actions,dependencies,arg, state;

  #the lookup for the new dependencies
  dependencies := [];
  #we go through all states
  for state in dom  do
    actions := SDComponentActions(state,t,rH2p,rN2p, rphi);
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

# H top level group
# phi: H -> Aut(N)
# N bottom level group
SemidirectCascade := function(H,phi,N)
  local rH, #regular representation of H
        rN, #regular representation of N
        dom, #the domain of the cascades (all coordinates), |H||N|
        comps, # cascade product components
        cascgens,rphi,i,autgens,gens,genHcoords,genNcoords,rHhom,rNhom,rH2p,rN2p;
  rHhom := RegIsom(H);
  rNhom := RegIsom(N);
  rH := Range(rHhom);
  rN := Range(rNhom);
  comps := [rH,rN];
  dom := EnumeratorOfCartesianProduct(ComponentDomains(comps));
  #get the generator sets
  gens := GeneratorsOfGroup(H);
  autgens := List(gens,g -> Image(phi,g));
  #make both sets regular
  gens := List(gens, g -> Image(rHhom,g));
  autgens := List(autgens, a -> RegularizeAutomorphism(a,rNhom));
  rphi := GroupHomomorphismByImages(
                  rH,
                  Group(autgens),
                  gens,
                  autgens);
  rH2p := Reg2Points(H);
  rN2p := Reg2Points(N);
  genHcoords := List(GeneratorsOfGroup(rH), g->[Image(rH2p,g),Image(rN2p,())]);
  genNcoords := List(GeneratorsOfGroup(rN), h->[Image(rH2p,()),Image(rN2p,h)]);
  cascgens := [];
  for i in Concatenation(genHcoords,genNcoords) do
    Add(cascgens,
        CascadeNC([rH,rN],
                SemidirectElementDepFuncT(i,
                        rH2p,
                        rN2p,
                        rphi,
                        dom)));
  od;
  return cascgens;
  #return  List(deps, x -> CascadeNC([rH,rN], x));
end;

CheckAllSemidirectProducts := function(H,N)
  local l,A,hom, gens, P1, P2;
  l := [];
  A := AutomorphismGroup(N);
  for hom in AllHomomorphismClasses(H,A) do
    P1 := SemidirectProduct(H,hom,N);
    Print(StructureDescription(P1),"#", Order(P1), " = \c");
    gens := List(SemidirectCascade(H,hom,N),
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
