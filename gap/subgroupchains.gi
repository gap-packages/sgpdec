#############################################################################
##
##  subgroupchains.gi           SgpDec Library
##
##  Copyright (C)  2003-2012, Attila Egri-Nagy, Chrystopher L. Nehaniv
##
##
## Subgroup chains of permutation groups.
##

SGPDEC_AddToSubgroupChain := function(chain, group)
    local preceding;
    if IsEmpty(chain) then Add(chain, group); fi;
    preceding := chain[Length(chain)];
    if not (IsSubgroup(preceding, group)) then
      Print("# W Tried to add a nonsubgroup to a subgroup chain.\n\c"); return;
    fi;
    if Size(preceding) > Size(group) then
        Add(chain, group);
    else
        Print("# W Tried to add the same group to a subgroup chain.\n\c");
    fi;
end;


###########################################################################
# Returns all proper normal subgroups. 
# Basically it removes the group itself and the trivial group.
ProperNormalSubgroups := function(G)
local nsgs,g,l;
  nsgs := NormalSubgroups(G);
  l := [];
  # as we are not sure whether the subgroups are ordered
  for g in nsgs do
    if (Size(g) > 1) and (Size(g) < Size(G)) then
      Add(l,g);
    fi;
  od;
  return l;
end;



###########################################################################
#Choosing subnormal series of a group interactively, step by step.
#The resulting chain is returned in a list, just like by CompositionSeries.
SGPDEC_iCreateChain := function(G, candidatefunction)
local i,ngs,str,l;

  l := [G];
  ngs := candidatefunction(G);

  while not IsEmpty(ngs) do
    #when we have no choice
    if Size(ngs) = 1 then
      SGPDEC_AddToSubgroupChain(l,ngs[1]);
      ngs := candidatefunction(ngs[1]);
      #otherwise do the interactive selection
    else
      for i in [1..Size(ngs)] do
        if SgpDecOptionsRec.SMALL_GROUPS then
          Print(i,". ",StructureDescription(ngs[i])," index ",
                Size(l[Length(l)])/Size(ngs[i]));
          if IsNormal(l[Length(l)], ngs[i]) then
            Print(" component ",
                  StructureDescription(FactorGroup(l[Length(l)],ngs[i])));
          fi;
          Print("\n\c");
        else
          Print(i,". size ",Size(ngs[i])," index ",
                Size(G)/Size(ngs[i]),"\n\c");
        fi;
      od;
      Print(1,"-",Size(ngs),"?\n\c");

      str := ReadLine(InputTextUser());
      RemoveCharacters(str,WHITESPACE);
      SGPDEC_AddToSubgroupChain(l,ngs[Int(str)]);
      ngs := candidatefunction(ngs[Int(str)]);
      ngs := ShallowCopy(ngs);
      SGPDEC_AddToSubgroupChain(ngs, Group(()));
    fi;
    Print("\n\c");
  od;
  # adding trivial group at the end of the list
  SGPDEC_AddToSubgroupChain(l,Group([()]));
  return List(l);
end;

InstallGlobalFunction(iCreateSubnormalChain,
function(G)
  return SGPDEC_iCreateChain(G,ProperNormalSubgroups);
end);

InstallGlobalFunction(iCreateMaximalSubgroupChain,
function(G)
  return SGPDEC_iCreateChain(G,MaximalSubgroupClassReps);
end);

ComponentWidths := function(chain)
local i,l;
  l := [];
  for i in [2..Length(chain)] do
    Add(l, Length(RightTransversal(chain[i-1], chain[i])));
   od;
  return l;
end;

InstallGlobalFunction(iStretchSubNormalChain,
function(chain)
local maxsubgroups, nchain,str,i,widths,level, nhom, F, gens;
  nchain := ShallowCopy(chain);
  widths := ComponentWidths(chain);
  for i in [1..Size(widths)] do
    Print(i,". ", widths[i] , "  ");ViewObj(chain[i]);Print( "\n");
  od;
  Print("Which level to stretch? ",1,"-",Size(widths),"?\n\c");

  str := ReadLine(InputTextUser());
  RemoveCharacters(str,WHITESPACE);
  level := Int(str);

  nhom := NaturalHomomorphismByNormalSubgroup(chain[level],chain[level+1]);
  F := Image(nhom);
  maxsubgroups := MaximalSubgroupClassReps(F);

  for i in [1..Size(maxsubgroups)] do
    Print(i,". ");ViewObj(maxsubgroups[i]);Print("\n");
  od;
  Print(1,"-",Size(maxsubgroups),"?\n\c");

  str := ReadLine(InputTextUser());
  RemoveCharacters(str,WHITESPACE);
  if SgpDecOptionsRec.SMALLER_GENERATOR_SET then
    Add(nchain,Group(PreImages(nhom,
            SmallGeneratingSet(maxsubgroups[Int(str)]))) , level + 1);
  else
    Add(nchain, Group(PreImages(nhom, maxsubgroups[Int(str)])), level + 1);
  fi;
  return nchain;
end);