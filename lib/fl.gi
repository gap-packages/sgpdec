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

# for a subgroupchain this calculates the right transversals and a group action
# on the cosets will define the components, thus the cosets are the coord vals
InstallGlobalFunction(CosetActionGroups,
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
# OriginalCosetActionReps := function(chain)
#   return RightTransversal(chain[1],chain[Length(chain)]);
# end;
OriginalCosetActionReps := function(G,x)
  local stabrt, stabrtreps,i;
  stabrt := RightTransversal(G,Stabilizer(G,x));
  stabrtreps := [];
  for i in [1..Length(stabrt)] do
    stabrtreps[x^stabrt[i]] := stabrt[i];
  od;
  return stabrtreps;
end;

# just a handy abbreviation: getting the representative of an element
CosetRep := function(g,transversal)
  return transversal[PositionCanonical(transversal,g)];
end;
MakeReadOnlyGlobal("CosetRep");

# decoding the integers back to coset representatives
Coords2CosetReps := function(cascstate, transversals)
  return List([1..Size(cascstate)],
              i -> transversals[i][cascstate[i]]);
end;
MakeReadOnlyGlobal("Coords2CosetReps");

# Each cascaded state corresponds to one element (in the regular representation)
#of the group. This function gives the path corresponding to a group element
#(through the Lagrange-Frobenius map).
InstallGlobalFunction(Perm2Coords,
function(g, transversals)
local coords,i;
  #on the top level we have simply g
  coords := [g];
  #then going down to deeper levels
  for i in [1..Length(transversals)-1] do
    Add(coords, coords[i] * Inverse(CosetRep(coords[i],transversals[i])));
  od;
  #taking the representative elements then coding coset reps as points (indices)
  return List([1..Size(coords)],
              i -> PositionCanonical(transversals[i], coords[i]));
end);

#mapping down is just multiplying together
InstallGlobalFunction(Coords2Perm,
function(cs, transversals)
    return Product(Reversed(Coords2CosetReps(cs, transversals)),());
end);

InstallMethod(FLCascadeGroup, "for a chain and stabilized point",
              [IsList, IsPosInt],
function(chain, x)
  local gens,id,cosetactions,G,flG;
  G := chain[1];
  cosetactions := CosetActionGroups(chain);
  id := IdentityCascade(cosetactions.components);
  flG := Group(List(GeneratorsOfGroup(G),
                 g->Cascade(cosetactions.components,
                         FLDependencies(g,
                                 cosetactions.transversals,
                                 DomainOf(id)))));
  SetIsFLCascadeGroup(flG,true);
  SetTransversalsOf(flG, cosetactions.transversals);
  SetOriginalCosetActionRepsOf(flG, OriginalCosetActionReps(G,x));
  SetComponentsOfCascadeProduct(flG,cosetactions.components);
  SetStabilizedPoint(flG, x);
  SetIsFinite(flG,true); #otherwise it gets a forced finiteness test
  return flG;
end);

InstallOtherMethod(FLCascadeGroup,
                   "for a chain",
                   [IsList],
function(chain)
  return FLCascadeGroup(chain,1);
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
  return Perm2Coords(OriginalCosetActionRepsOf(FLG)[i], st);
end);

#coords -> point, the Frobenius-Lagrange map TODO this assumes transitivity
InstallGlobalFunction(AsFLPoint,
function(cs,FLG)
  return StabilizedPoint(FLG)
         ^
         Product(Reversed(Coords2CosetReps(cs,TransversalsOf(FLG))),());
end);

AsFLCascade := function(g, FLG)
  return Cascade(ComponentsOfCascadeProduct(FLG),
                 FLDependencies(g,
                                TransversalsOf(FLG),
                                DomainOf(FLG)));  
end;

AsFLPermutation := function(co, FLG)
  return PermList(List([1..Size(OriginalCosetActionRepsOf(FLG))],
                       x-> AsFLPoint(OnCoordinates(AsFLCoords(x,FLG),co),FLG)));
end;

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
  s := Coords2CosetReps(s,transversals);
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
  decoded := Coords2CosetReps(cs, transversals);
  killers := [];
  for cosetrepr in decoded do
    Add(killers,Inverse(cosetrepr));
  od;
  return killers;
end);

InstallGlobalFunction(LevelBuilders,
function(cs, transversals)
local decoded, cosetrepr, builders;
  decoded := Coords2CosetReps(cs, transversals);
  builders := [];
  for cosetrepr in decoded do
    Add(builders,cosetrepr);
  od;
  return builders;
end);


TestFL := function(states, G, FL)
  local  x, g, FLx, FLg;
  for x in states do
    for g in Generators(G) do
      FLx := AsFLCoords(x,FL);
      FLg := AsFLCascade(g,FL);
      if (x^g) = AsFLPoint(FLx^FLg, FL) then
        Print("#\c");
      else
        Print(x^g," expected, found: ",  AsFLPoint(FLx^FLg, FL),"\n" );
      fi;
    od;
  od;
  Print("\n");
end;  
