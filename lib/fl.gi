#############################################################################
##
## fl.gi           SgpDec package
##
## Copyright (C) 2008-2019
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Frobenius-Lagrange decomposition. Cascade groups built from components
## acting on coset spaces determined by a subgroup chain.
##

# coords integers encoding coset representatives
# reps coset representatives
# point state
# perm permutation

# for a subgroupchain this calculates the right transversals and a group action
# on the cosets will define the components, thus the cosets are the coord vals
InstallGlobalFunction(FLComponents,
function(subgroupchain)
local transversals, comps,i,compgens;
  transversals := [];
  comps := [];
  for i in [1..Length(subgroupchain)-1] do
    #the transversals - coset spaces
    transversals[i] := RightTransversal(subgroupchain[i],subgroupchain[i+1]);
    #the generators of the component by the canonical action on the cosets
    compgens := List(GeneratorsOfGroup(subgroupchain[i]),
                     gen -> AsPermutation(
                             TransformationOp(gen,transversals[i],OnRight)));
    #getting rid of identity permutations
    compgens := Filtered(compgens, gen-> not IsOne(gen));
    #getting rid of duplicate generators, creating the groups
    Add(comps,Group(AsSet(compgens)));
  od;
  return rec(transversals:=transversals,components:=comps);
end);

# we want to keep the original action of the group to be decomposed
# since any action is a coset action all we need is the coset space
# of the stabilizer of a point
BottomCosetActionReps := function(G,bottomG,x)
  local stabrt, stabrtreps,i;
  stabrt := RightTransversal(G,bottomG);
  stabrtreps := [];
  for i in [1..Length(stabrt)] do
    stabrtreps[x^stabrt[i]] := stabrt[i];
  od;
  return stabrtreps;
end;
MakeReadOnlyGlobal("BottomCosetActionReps");

ValidPoints := function(FLG)
  local l;
  l := BottomCosetActionRepsOf(FLG);
  return Filtered([1..Length(l)], x -> IsBound(l[x]));
end;  

# just a handy abbreviation: getting the representative of an element
CosetRep := function(g,transversal)
  return transversal[PositionCanonical(transversal,g)];
end;
MakeReadOnlyGlobal("CosetRep");


# a permutation is coordinatized by coset representatives
InstallGlobalFunction(Perm2Reps,
function(g, transversals)
  local reps,i;
  #on the top level we have simply g
  reps := [g];
  #then going down to deeper levels
  for i in [1..Length(transversals)-1] do
    Add(reps, reps[i] * Inverse(CosetRep(reps[i],transversals[i])));
  od;
  return reps;
end);

InstallGlobalFunction(Reps2FLCoords,
function(reps, transversals)
  #taking the representative elements then coding coset reps as points (indices)
  return List([1..Size(reps)],
              i -> PositionCanonical(transversals[i], reps[i]));
end);

# decoding the integers back to coset representatives
InstallGlobalFunction(FLCoords2Reps,
function(cascstate, transversals)
  return List([1..Size(cascstate)],
              i -> transversals[i][cascstate[i]]);
end);

# permutation converted coset reps, then integer encoding
InstallGlobalFunction(Perm2FLCoords,
function(g, transversals)
  return Reps2FLCoords(Perm2Reps(g, transversals),transversals);
end);

#mapping down is just multiplying together
InstallGlobalFunction(FLCoords2Perm,
function(cs, transversals)
    return Product(Reversed(FLCoords2Reps(cs, transversals)),());
end);

CreateFLCascadeGroup := function(chain)
local gens,id,cosetactions,G,flG;
  G := chain[1];
  cosetactions := FLComponents(chain);
  id := IdentityCascade(cosetactions.components);
  flG := Group(List(GeneratorsOfGroup(G),
                    g->Cascade(cosetactions.components,
                               FLDependencies(g,
                                              cosetactions.transversals,
                                              DomainOf(id)))));
  SetIsFLCascadeGroup(flG,true);
  SetTransversalsOf(flG, cosetactions.transversals);
  SetComponentsOfCascadeProduct(flG,cosetactions.components);
  SetIsFinite(flG,true); #otherwise it gets a forced finiteness test
  return flG;
end;
MakeReadOnlyGlobal("CreateFLCascadeGroup");

InstallMethod(FLCascadeGroup,
"for a subgroup chain (with a point stabilizer at the bottom) and stabilized point",
[IsList, IsPosInt],
function(chain, x)
  local flG;
  flG := CreateFLCascadeGroup(chain);
  SetBottomCosetActionRepsOf(flG, BottomCosetActionReps(chain[1],chain[Length(chain)],x));
  SetStabilizedPoint(flG, x);
  return flG;
end);

InstallOtherMethod(FLCascadeGroup,
                   "for a subgroup chain",
                   [IsList],
function(chain)
  local flG;
  flG := CreateFLCascadeGroup(chain);
  SetBottomCosetActionRepsOf(flG, RightTransversal(chain[1],chain[Length(chain)]));
  return flG;
end);

InstallOtherMethod(FLCascadeGroup,
                   "for a group",
                   [IsGroup],
function(G)
  return FLCascadeGroup(ChiefSeries(G),1);
end);

#gives a coordinate representation of an original point
InstallGlobalFunction(AsFLCoords,
function(i,FLG)
  local st;
  st := TransversalsOf(FLG);
  return Perm2FLCoords(BottomCosetActionRepsOf(FLG)[i], st);
end);

#coords -> point, the Frobenius-Lagrange map TODO this assumes transitivity
InstallGlobalFunction(AsFLPoint,
function(cs,FLG)
  if HasStabilizedPoint(FLG) then                     
    return StabilizedPoint(FLG)
           ^
           Product(Reversed(FLCoords2Reps(cs,TransversalsOf(FLG))),());
  else
    return PositionCanonical(BottomCosetActionRepsOf(FLG),
                             FLCoords2Perm(cs, TransversalsOf(FLG)));
  fi;
end);

# group element to perm cascade
InstallGlobalFunction(AsFLCascade,
function(g, FLG)
  return Cascade(ComponentsOfCascadeProduct(FLG),
                 FLDependencies(g,
                                TransversalsOf(FLG),
                                DomainOf(FLG)));  
end);

InstallGlobalFunction(AsFLPermutation,
function(co, FLG)
  local l,i;
  l := [];
  for i in  ValidPoints(FLG) do
    l[i] := AsFLPoint(OnCoordinates(AsFLCoords(i,FLG),co),FLG);
  od;
  return PermList(List([1..Size(l)],
  function(x)
    if IsBound(l[x]) then return l[x]; else return x;fi;
  end));
end);

InstallMethod(IsomorphismPermGroup, "for a Frobenius-Lagrange cascade group",
[IsFLCascadeGroup],
function(FLG)
  local H,f,invf;
  f := co -> AsFLPermutation(co, FLG);
  invf := g -> AsFLCascade(g,FLG);
  H := Group(List(GeneratorsOfGroup(FLG),f));
  return MagmaIsomorphismByFunctionsNC(FLG, H, f, invf);
end);

# s - state (list), g - group element to be lifted,
InstallGlobalFunction(FLComponentActions,
function(g,s, transversals)
  local fudges,i;
  s := FLCoords2Reps(s,transversals);
  #on the top level we have simply g
  fudges := [g];
  #then going down to deeper levels
  for i in [2..Length(s)] do
    Add(fudges,
        s[i-1] * #this is already a representative!
        fudges[i-1] *
        Inverse(CosetRep(s[i-1] * fudges[i-1],
                transversals[i-1])));
  od;
  #converting to coset action
  return List([1..Length(fudges)],
              i -> AsPermutation(
                      TransformationOp(fudges[i],transversals[i],\*)));
end);

InstallGlobalFunction(FLDependencies,
function(g,transversals, dom)
local i,state,actions,depfuncs;
  #identity needs no further calculations
  if g=() then return [];fi;
  depfuncs := [];
  #we go through all states
  for state in dom do
    #get the component actions on a state
    actions := FLComponentActions(g,state,transversals);
    #examine whether there is a nontrivial action, then add
    for i in [1..Length(actions)] do
      if actions[i] <> () then
        AddSet(depfuncs,[state{[1..(i-1)]},actions[i]]);
      fi;
    od;
  od;
  return depfuncs; #TODO maybe sort them into a graded list
end);

#given a cascaded state it returns an array of flat cascops that -
#applied in order - kills of levels top-down.
InstallGlobalFunction(LevelKillers,
function(cs, transversals)
local decoded, cosetrepr, killers;
  decoded := FLCoords2Reps(cs, transversals);
  killers := [];
  for cosetrepr in decoded do
    Add(killers,Inverse(cosetrepr));
  od;
  return killers;
end);

InstallGlobalFunction(LevelBuilders,
function(cs, transversals)
local decoded, cosetrepr, builders;
  decoded := FLCoords2Reps(cs, transversals);
  builders := [];
  for cosetrepr in decoded do
    Add(builders,cosetrepr);
  od;
  return builders;
end);

# testing the group action isomorphism, only for transitive actions
# where the last element of the chain is a stabilizer of a point
# and that point is given
TestFLAction := function(states, G, FL)
  local  x, g, FLx, FLg;
  for x in states do
    for g in Generators(G) do
      FLx := AsFLCoords(x,FL);
      FLg := AsFLCascade(g,FL);
      if (x^g) <> AsFLPoint(FLx^FLg, FL) then
        Print(x^g," expected, found: ",  AsFLPoint(FLx^FLg, FL),"\n" );
      fi;
    od;
  od;
  return true;
end;  
MakeReadOnlyGlobal("TestFLAction");

# for testing a coset action (for subgroup chains not necessarily ending
# in a point stabilizer)
TestFLCosetAction := function(G, FL)
  local  x, g, FLx, FLg;
  for x in BottomCosetActionRepsOf(FL) do
    for g in Generators(G) do
      FLx := Perm2FLCoords(x,TransversalsOf(FL));
      FLg := AsFLCascade(g,FL);
      if PositionCanonical(BottomCosetActionRepsOf(FL), x*g) <> AsFLPoint(FLx^FLg, FL) then
        Print(PositionCanonical(BottomCosetActionRepsOf(FL), x*g),
              " expected, found: ",  AsFLPoint(FLx^FLg, FL),"\n" );
        return false;
      fi;
    od;
  od;
  return true;
end;  
MakeReadOnlyGlobal("TestFLCosetAction");

#displays the components of an FL cascade group
#if a series is given, it computes these components
InstallGlobalFunction(DisplayFLComponents,
function(FLG_or_series)
  local comps, trvs, i, r;
  if IsCascadeGroup(FLG_or_series) then
    comps := ComponentsOfCascadeProduct(FLG_or_series);
    trvs := TransversalsOf(FLG_or_series);
  else
    r := FLComponents(FLG_or_series);
    comps := r.components;
    trvs := r.transversals;
  fi;
  for i in [1..Size(comps)] do
    Print(i,": (", Size(trvs[i]),",");
    if SgpDecOptionsRec.SMALL_GROUPS then
      Print(StructureDescription(comps[i]));
    else
      Print("group of size ",Size(comps[i]));
    fi;
    Print(")\n");
  od;
end);
