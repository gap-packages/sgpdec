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

StabilizerReps := function(G)
local stabrt, stabrtreps,i;
  stabrt := RightTransversal(G,Stabilizer(G,1));
  stabrtreps := [];
  for i in [1..Length(stabrt)] do
    stabrtreps[1^stabrt[i]] := stabrt[i];
  od;
  return stabrtreps;
end;
