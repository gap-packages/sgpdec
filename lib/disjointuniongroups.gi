#############################################################################
##
## disjointunion.gi           SgpDec package
##
## Copyright (C) 2008-2022
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
  origens := GeneratorsOfGroup(G); # original generators
  gens := List(origens, x -> [1..n+shift]); # identity maps
  for j in [1..Size(gens)] do
    for i in [1..n] do
      gens[j][i+shift] := OnPoints(i,origens[j]) + shift;
    od;
  od;
  return Group(List(gens, x -> PermList(x)));
end);

# given a list of groups it returns the vector of shifts, where the ith entry
# tells how much the ith grouph is to be shifted,
# the last element tells the total number of points to act on
InstallGlobalFunction(ShiftVector,
function(groups)
local shifts;
  shifts := [0]; # the first group needs no shifting
  Perform(groups,
         function(G)
           Add(shifts, shifts[Length(shifts)] + LargestMovedPoint(G));
         end);
  return shifts;
end);

# Creates a disjoint union of the given groups by shifting their actions
# and padding their generators.
# 1st arg: list of permutation groups
# 2nd arg: vector of shifts
# if your shift vector contains overlaps, then you get something funny
InstallGlobalFunction(DisjointUnionPermGroup,
function(groups, shifts)
  local gens,shiftedgroups,n;
  n := shifts[Length(shifts)];
  #now shift the groups
  shiftedgroups := List([1..Size(groups)],
                        i->ShiftGroupAction(groups[i],shifts[i]));
  #add the permutation generators
  gens := [];
  Perform(shiftedgroups, function(G) Append(gens,GeneratorsOfGroup(G));end);
  return Group(gens);
end);
