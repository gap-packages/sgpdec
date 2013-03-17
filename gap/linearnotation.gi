##########################################################################
##
## linearnotation.gi           SgpDec package
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## 2009-2012
## One line notation for transformations.

# Finding the components of a transformation, i.e.  the disconnected subgraphs
# of its functional digraph.
# A component is a list of points, and the components are returned in a list.
TransformationComponents := function(t)
local visited,comps, i,actualcomp;
  comps := [];           #components will be represented as list of points
  visited := [];         #we keep track of the points we visited already
  #seemingly going through all points...
  for i in [1..DegreeOfTransformation(t)] do
    #...but skipping those that are already in some component
    if not (i in visited) then
      Add(comps,[]); #let's start with a fresh new component
      actualcomp := comps[Length(comps)]; #make the last to the actual one
      repeat
        AddSet(actualcomp,i);
        AddSet(visited,i);
        i := i ^ t;
      until i in visited; #keep adding until we bump into something known
      if not (i in actualcomp) then #known but not in actual component -> merge
        Append(First(comps, c -> i in c), actualcomp);
        Remove(comps); # & remove the last component
      fi;
    fi;
  od;
  return comps;
end;
MakeReadOnlyGlobal("TransformationComponents");

#Find the points in the cycle in a component containing the initial point.
CycleOfTransformationFromPoint := function(t,p)
local orbit;
  orbit := []; #we generate the orbit
  while not (p in orbit) do
    AddSet(orbit,p);
    p := p ^ t;
  od;
  #p is repeated so we can  cut out the cycle
  return orbit{[Position(orbit,p)..Length(orbit)]};
end;
MakeReadOnlyGlobal("CycleOfTransformationFromPoint");

################################################################################
# Recursively prints the tree incoming into a point. The point's cycle also
# needs to be known to exclude tho preimages in the cycle.
# point - the root of the tree,
# t - transformation,
# cycle - the cycle of the component
# str - the buffer string in which to print
TreePrint := function(point, t,cycle, str)
local preimgs,p;
  #we reverse the arrows in the graph for the recursion, but not the cycle
  preimgs := Difference(PreimagesOfTransformation(t, point),cycle);
  if IsEmpty(preimgs) then   #if it is a terminal point, just print it
    str := Concatenation(str,String(point));
    return str;
  fi;
  str := Concatenation(str,"["); #starting the tree notation
  for p in preimgs do
    str := TreePrint(p,t,cycle,str);
    str := Concatenation(str,",");
  od;
  if str[Length(str)] = ',' then Remove(str); fi; #removing unnecessary comma
  str := Concatenation(str,";");
  str := Concatenation(str,String(point),"]"); # ending the tree notation
  return str;
end;
MakeReadOnlyGlobal("TreePrint");

#Returns the linear notation of the transformation in a string
InstallGlobalFunction(LinearNotation,
function(t)
  local comp,cycle,point,str;
  #this special case would be difficult to handle
  if IsOne(t) then return "()";fi;
  str := "";
  for comp in TransformationComponents(t) do
    if Size(comp) = 1 then continue; fi;#fixed points are not displayed
    #1-cycles are not displayed as cycles (but it can be a tree)
    cycle := CycleOfTransformationFromPoint(t,comp[1]);
    if (Length(cycle) > 1) then #if it is a permutation
      str := Concatenation(str,"(");
    fi;
    for point in cycle do
      str := TreePrint(point,t,cycle,str);
      str := Concatenation(str,",");
    od;
    Remove(str); #removing unnecessary last comma
    if (Length(cycle) > 1 ) then
      str := Concatenation(str,")");
    fi;
  od;
  return str;
end);

#constant maps are further simplified
InstallGlobalFunction(SimplerLinearNotation,
 function(t)
 if RankOfTransformation(t) = 1 then
  return Concatenation("[->", String(1^t),"]");
 else
  return LinearNotation(t);
 fi;
end);

#redefining display for transformations if user
#wants linearnotaion
if SgpDecOptionsRec.LINEAR_NOTATION then
  InstallMethod( ViewObj,
    "linear notation for transformations",
    true,
    [IsTransformation], 0,
  function(t)
    Print(SimplerLinearNotation(t));
  end);
fi;
