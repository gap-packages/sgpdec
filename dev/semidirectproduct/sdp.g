### REGULAR REPRESENTATION #####################################################

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

#elements of the regular representation coded as integers
Reg2Points := function(G)
  return CompositionMapping(Elts2Points(G),
                 InverseGeneralMapping(RegIsom(G)));
end;

#converting a group automorphism to a the corresponding
#automorphism on the regular representation
RegularizeAutomorphism := function(aut,reghom)
  return CompositionMapping(reghom,
                 CompositionMapping(aut, InverseGeneralMapping(reghom)));
end;

### SEMIDIRECT #################################################################
SDComponentActions := function(g1,g2,rH2p, rN2p, rtheta)
  local ca, h1,h2,n2,theta;
  ca := [];
  h1 := PreImage(rH2p, g1[1]);
  h2 := PreImage(rH2p, g2[1]);
  #top level action
  ca[1] := h2;
  #n1 does not matter
  n2 := PreImage(rN2p, g2[2]);
  theta := Image(rtheta, h1);
  #bottom level action
  ca[2] := Image(theta, n2);
  return ca;
end;

SemidirectElementDepFuncT := function(t,rH2p, rN2p, rtheta, dom)
local j,actions,dependencies,arg, state;

  #the lookup for the new dependencies
  dependencies := [];
  #we go through all states
  for state in dom  do
    actions := SDComponentActions(state,t,rH2p,rN2p, rtheta);
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

# H top level group
# theta: H -> Aut(N)
# N bottom level group
SemidirectCascade := function(H,theta,N)
  local rH, #regular representation of H
        rN, #regular representation of N
        dom, #the domain of the cascades (all coordinates), |H||N|
        comps, # cascade product components
        cascgens, #the generator cascades (the actual output)
        rtheta, #Reg(H) -> Reg(Aut(N))
        sdpelt, #elements of the semidirect product represent as 2-tuples
        autgens,gens,genHcoords,genNcoords,rHhom,rNhom,rH2p,rN2p;
  # making the components into regular representation
  rHhom := RegIsom(H);
  rNhom := RegIsom(N);
  rH := Range(rHhom);
  rN := Range(rNhom);
  comps := [rH,rN];
  dom := EnumeratorOfCartesianProduct(ComponentDomains(comps));
  #get the generator sets of H and theta
  gens := GeneratorsOfGroup(H);
  autgens := List(gens,g -> Image(theta,g));
  #make both sets regular
  gens := List(gens, g -> Image(rHhom,g));
  autgens := List(autgens, a -> RegularizeAutomorphism(a,rNhom));
  rtheta := GroupHomomorphismByImages(
                  rH,
                  Group(autgens),
                  gens,
                  autgens);
  rH2p := Reg2Points(H);
  rN2p := Reg2Points(N);
  genHcoords := List(GeneratorsOfGroup(rH), g->[Image(rH2p,g),Image(rN2p,())]);
  genNcoords := List(GeneratorsOfGroup(rN), h->[Image(rH2p,()),Image(rN2p,h)]);
  cascgens := [];
  for sdpelt in Concatenation(genHcoords,genNcoords) do
    Add(cascgens,
        CascadeNC([rH,rN],
                SemidirectElementDepFuncT(sdpelt,
                        rH2p,
                        rN2p,
                        rtheta,
                        dom)));
  od;
  return cascgens;
end;

### CHECK ######################################################################

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

### UTIL #######################################################################
#print general mappings on the screen
PrintMappings := function(genmap)
  Perform(Source(genmap), function(x)Print(x,"->",Image(genmap,x),"\n") ;end);
end;
