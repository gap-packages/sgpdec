##########################################################################
##
## uldg.gi           SgpDec package  
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
## 2009 University of Hertfordshire, Hatfield, UK
##
## Functions for giving generators for special uniquely labelled 
## state transition graphs. 

## 1. PART 
##Functions for making transformation(s) from elementary collapsing(s).
#n - we need to know the number of points to act on 

InstallGlobalFunction(TransformationFromElementaryCollapsing,
function(collapsing, n)
local l;
  l := [1..n];
  l[collapsing[1]] := collapsing[2];
  return Transformation(l);
end
);

#returns a set of transformations corresponding to the elementray collapsings
#collapsings - list of pairs
InstallGlobalFunction(TransformationsFromElementaryCollapsings,
function(collapsings, n)
  return List(collapsings, collapsing -> TransformationFromElementaryCollapsing(collapsing,n));  
end
);


#2. PART the graphs
#cycle with shortcut
InstallGlobalFunction(GammaGraph,
function(l,k)
local collapsings,i;
  collapsings := [];
  #the cycle
  for i in [1..l-1] do
    Add(collapsings, [i,i+1]);
  od;
  Add(collapsings, [l,1]);
  #the shortcut
  Add(collapsings, [1,k]);
  return collapsings;
end);

#touching cycles
InstallGlobalFunction(DeltaGraph,
function(m,n)
local collapsings,i,k;
  collapsings := [];
  #the 1st cycle
  for i in [1..m-1] do
    Add(collapsings, [i,i+1]);
  od;
  Add(collapsings, [m,1]);
  #the 2nd cycle
  k := m + n -1;
  Add(collapsings, [1,m+1]);
  for i in [m+1..k-1] do
    Add(collapsings, [i,i+1]);
  od;
  Add(collapsings, [k,1]);

  return collapsings;
end);

InstallGlobalFunction(OldBetaGraph,
function(k,l,m)
local collapsings,i;
  collapsings := [];
  #the common part
  for i in [1..k-1] do
    Add(collapsings, [i,i+1]);
  od;
  #the 1st cycle
  for i in [k..k+l-1] do
    Add(collapsings, [i,i+1]);
  od;
  Add(collapsings,[k+l,1]);

  #the 2nd cycle
  Add(collapsings,[k,k+l+1]);
  for i in [k+l+1..k+l+m-1] do
    Add(collapsings, [i,i+1]);
  od;
  Add(collapsings,[k+l+m,1]);

  return collapsings;
end);

InstallGlobalFunction(BetaGraph,
function(k,l,m)
#shared part not be longer than cycles being glued together
 if (m >= Minimum(k,l) or Minimum(k,l) < 2) then return fail; fi;
 # m is the number of shared EDGES , so add one since OldBetaGraph takes nodes
 return OldBetaGraph(m+1, k-m-1, l-m-1);
end);

InstallGlobalFunction(ThetaGraph,
function(k,l,m) # cycle of length k and l, sharing m edges.
local collapsings,cycle1,cycle2,i,shift;
  collapsings := [];
  cycle1 := [];
  cycle2 := [];


  # at least one edge per cycle must be not shared
  if m >= Minimum(k,l) then return fail; fi; 
  shift := k-m-1;
  if shift < 0 then return fail; fi;

  #the 1st cycle
  for i in [1..k-1] do
    Add(cycle1, [i,i+1]);
  od;
  Add(cycle1,[k,1]);

  #the 2nd cycle -- start it at k-m

  for i in [1..l-1] do
    Add(cycle2, [i,i+1]+[shift,shift]);
  od;
  Add(cycle2,[l,1]+[shift,shift]);

  collapsings := Union(cycle1,cycle2);

  return collapsings;
end);

