#############################################################################
##
## permgrouputils.g           SgpDec package  
##
## Copyright (C)  2011 Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Extra utility functions for dealing with permutation groups.
##


#creates a permutation from individual maps (like from spare matrix to a fully stored one)
PermFromIndividualMaps := function(maps, size)
local l, map; 
  l := [1..size];
  for map in maps do
    l[map[1]] := map[2];
  od; 
  return PermList(l);
end;


