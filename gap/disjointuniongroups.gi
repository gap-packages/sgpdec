#############################################################################
##
## disjointunion.gi           SgpDec package
##
## Copyright (C) 2008-2015
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Disjoint union of permutation groups (by shifted actions).
##

#shifts the points of the action
# 1st arg G - permutation group,
# 2nd arg shift - the amount the action is shifted by
InstallGlobalFunction(ShiftGroupAction,
function(G,shift)
local gens,origens,i,j,n;
  n := LargestMovedPoint(G);
  origens := GeneratorsOfGroup(G);
  gens := List(origens, x -> [1..n+shift]);#identity maps
  for i in [1..n] do
    for j in [1..Size(gens)] do
      gens[j][i+shift] := OnPoints(i,origens[j]) + shift;
    od;
  od;
  return Group(List(gens, x -> PermList(x)));
end);

# 1st arg: list of permutation groups
# 2nd arg: optional, vector of shifts, ith entry tells how much
# the ith grouph is to be shifted, the last element tells the total
# number of points to act on
# if your shift vector contains overlaps, then you get something funny
# if the shift vector is not given, then it is calculated by moved points
InstallGlobalFunction(DisjointUnionPermGroup,
function(arg)
  local gens,shiftedgroups,groups,shifts,n;
  groups := arg[1];
  #get the shifts from the second argument
  if IsBound(arg[2]) then
    shifts := arg[2];
  else
    shifts := [0];
    Perform(groups,
            function(G)
              Add(shifts, shifts[Length(shifts)] + LargestMovedPoint(G));
            end);
  fi;
  n := shifts[Length(shifts)];
  #now shift the groups
  shiftedgroups := List([1..Size(groups)],
                        i->ShiftGroupAction(groups[i],shifts[i]));
  #add the permutation generators
  gens := [];
  Perform(shiftedgroups, function(G) Append(gens,GeneratorsOfGroup(G));end);
  return Group(gens);
end);
