# for a subgroupchain it calculates the right transversals and a group action on
# the cosets
# in Frobenius-Lagrange decompositions these are the coordinates and components
CosetActionGroups := function(subgroupchain)
local transversals, comps,i,compgens;
  transversals := [];
  comps := [];
  for i in [1..Length(subgroupchain)-1] do
    #first the transversals
    transversals[i] := RightTransversal(subgroupchain[i],subgroupchain[i+1]);
    # then the generators of the component by the canonical action on the
    # transversals
    compgens := List(GeneratorsOfGroup(subgroupchain[i]),
         gen -> AsPermutation(TransformationOp(gen,transversals[i],OnRight)));
    compgens := Filtered(compgens, gen-> not IsOne(gen));
    Add(comps,Group(AsSet(compgens)));
  od;
  return rec(transversals:=transversals,
             components:=comps);
end;

# what group elements correspond to the integers
StabilizerCosetActionReps := function(G)
local stabrt, stabrtreps,i;
  stabrt := RightTransversal(G,Stabilizer(G,1));
  stabrtreps := [];
  for i in [1..Length(stabrt)] do
    stabrtreps[1^stabrt[i]] := stabrt[i];
  od;
  return stabrtreps;
end;

# getting the representative of an element
CosetRep := function(g,transversal)
  return transversal[PositionCanonical(transversal,g)];
end;

# Each cascaded state corresponds to one element (in the regular representation)
#of the group. This function gives the path corresponding to a group element
#(through the Lagrange-Frobenius map).
Perm2Coords := function(g, transversals)
local coords,i;
  #on the top level we have simply g
  coords := [g];
  #then going down to deeper levels
  for i in [1..Length(transversals)-1] do
    Add(coords, coords[i] * Inverse(CosetRep(coords[i],transversals[i])));
  od;
  #taking the representative elements then coding coset reps as points (indices)
  coords := List([1..Length(coords)],
                 i -> PositionCanonical(transversals[i],
                         CosetRep(coords[i], transversals[i])));
  return coords;
end;
