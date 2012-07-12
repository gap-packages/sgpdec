


################################################################
# Returns true if the permutation is even.
IsEvenPerm := function(perm) return SignPerm(perm) = 1;end;

################################################################
# Returns true if the permutation is odd.
IsOddPerm := function(perm) return SignPerm(perm) = -1;end;

######MAPPING RELATED###########################################

##############################################################################
# for displaying general mappings, bijectivity indicated
MappingTable := function(map)
local i,s;
  if IsBijective (map) then
      s := " <--> ";
  else
      s := " --> ";
  fi;

  for i in Elements(Source(map)) do Print(i,s,Image(map,i),"\n"); od;
end;
