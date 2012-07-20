##########################################################################
##
## linearnotation.gi           SgpDec package
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## 2009-2012
## One line notation for transformations.

# Finding the components of a transformation (the disconnected subgraphs).
# A component is a list of points, and the components are returned in a list.
TransformationComponents := function(t)
local visited,comps, i,actualcomp;
  comps := [];           #components will be represented as list of points
  visited := [];         #we keep track of the points we visited already
  #seemingly going through all points...
  for i in [1..DegreeOfTransformation(t)] do
    #...but skipping those that are already in some component
    if not (i in visited) then
      Add(comps,[]);    #let's start with a fresh new component
      actualcomp := comps[Length(comps)]; #make it the actual one
      repeat 
        Add(actualcomp,i);
        Add(visited,i);
        i := i ^ t;
      until i in visited; #keep adding until we bump into soemthing known
      if not (i in actualcomp) then #known but not in actual component -> merge & remove
        Append(First(comps, c -> i in c), actualcomp);
        Remove(comps);
      fi;
    fi;
  od;
  return comps;
end;

#Find the points in the cycle in a component containing the initial point.
CycleOfTransformationFromPoint := function(t,p)
local orbit;
  orbit := []; #we generate the orbit
  while not (p in orbit) do
    Add(orbit,p);
    p := p ^ t;
  od;
  #p is repeated so we can  cut out the cycle
  return orbit{[Position(orbit,p)..Length(orbit)]};
end;

##############################################
# point - the root of the tree, transformation,
#the list of the cycle elements, the string
TreePrint := function(point, transformation,cycle, str)
local preimgs,p;

  #we reverse the arrows in the graph for the recursion
  preimgs := PreimagesOfTransformation(transformation, point);
  if IsEmpty(preimgs) then   #if it is a terminal point, just print it
    str := Concatenation(str,String(point));
    return str;
  fi;
  
  str := Concatenation(str,"["); #starting the tree notation
  for p in preimgs do
    #if we are tracing the tree, not the cycle the recursion
    if point <> p and (not p in cycle)then
      str := TreePrint(p,transformation,cycle,str);
      str := Concatenation(str,",");
    fi;
  od;
  if str[Length(str)] = ',' then Remove(str); fi; #removing unnecessary comma
  if (Size(preimgs) > 1)
     or (preimgs[1] <> point and not (preimgs[1] in cycle)) then
    str := Concatenation(str,";");
  fi;
  str := Concatenation(str,String(point),"]"); # ending the tree notation
  return str;
end;
MakeReadOnlyGlobal("TreePrint");

#Returns the linear notation of the transformation in a string
InstallGlobalFunction(LinearNotation,
function(transformation)
  local components,comp,cycle,point,str;
  #this special case would be difficult to handle
  if IsOne(transformation) then return "()";fi;
  str := "";
  components := TransformationComponents(transformation);
  for comp in components do
    if Size(comp) = 1 then continue; fi;#fixed points are not displayed
    #1-cycles are not displayed as cycles (but it can be a tree)
    cycle := CycleOfTransformationFromPoint(transformation,comp[1]);
    if (Length(cycle) > 1 ) then str := Concatenation(str,"(");fi;
    for point in cycle do
      if IsSubset(AsSet(cycle), AsSet(PreimagesOfTransformation(transformation, point))) then
        #preimages are all in the cycle -> no incoming tree, just print the point
        str := Concatenation(str,String(point));
      else
        #print the incoming tree
        str := TreePrint(point,transformation,cycle,str);
      fi;
      str := Concatenation(str,",");
    od;
    Remove(str); #removing last comma
    if (Length(cycle) > 1 ) then str := Concatenation(str,")");fi;
  od;
  return str;
end);

#constant maps are further simplified
InstallGlobalFunction(SimplerLinearNotation,
 function(transformation)
 if RankOfTransformation(transformation) = 1 then
  return Concatenation("[->", String(transformation![1][1]),"]");
 else
  return LinearNotation(transformation);
 fi;
end);

#redefining display for transformations if user
#wants linearnotaion
if SgpDecOptionsRec.LINEAR_NOTATION then
  InstallMethod( ViewObj,
    "linear notation for transformations",
    true,
    [IsTransformation], 0,
  function( t )
    Print(SimplerLinearNotation(t));
  end);
fi;