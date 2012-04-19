##########################################################################
##
## linearnotation.gi           SgpDec package  
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
## 2009 University of Hertfordshire, Hatfield, UK
## One line notation for transformations.

SGPDEC_LinearNotation_Transformation2Mapping := function(t)
local dom;
  dom := Domain([1..DegreeOfTransformation(t)]);
  return MappingByFunction(dom,dom, x -> x^t);
end;

# Finding the components of a transformation (the disconnected subgraphs).
# A component is a list of points, and the components are returned in a list.
TransformationComponents := function(t)
local visited,comps, i,actualcomp,comp;
  comps := [];           #components will be represented as list of points
  visited := [];         #we keep track of the points we visited already
  #seemingly going through all points...
  for i in [1..DegreeOfTransformation(t)] do
    #...but skipping those that are already in some component
    if not (i in visited) then
      Add(comps,[i]);    #let's start with a fresh new component
      actualcomp := LastElementOfList(comps);
      Add(visited,i);
      i := i ^ t;        #keep going with the orbit till we bump into something known
      while not (i in  visited) do
        Add(actualcomp,i);
        Add(visited,i);
        i := i ^ t;
      od;
      #if we found an element that is another components then we need to merge components
      if not (i in actualcomp) then
        #merging to actual component to a previous one
        for comp in comps do
          if i in comp then
            Append(comp, actualcomp);
            Remove(comps);
            break;
          fi;
        od; 
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
  #and if a point is repeated  cut the cycle out
  return orbit{[Position(orbit,p)..Length(orbit)]};
end;

##############################################
# point - the root of the tree, mapping the whole transformation as Mapping, the list of the cycle elements, the string
SGPDEC_LinearNotation_TreePrint := function(point, mapping,cycle, str)
    local preimgs,p;

    preimgs := PreImages(mapping, point); #we reverse the arrows in the graph for the recursion
    if IsEmpty(preimgs) then   #if it is a terminal point, just print it
      str := Concatenation(str,StringPrint(point));
      return str;
    fi;

    str := Concatenation(str,"["); #starting the tree notation
    for p in preimgs do
      if point <> p and (not p in cycle)then #if we are tracing the tree, not the cycle the recursion
        str := SGPDEC_LinearNotation_TreePrint(p,mapping,cycle,str);
        str := Concatenation(str,",");
      fi;
    od;
  if LastElementOfList(str) = ',' then Remove(str); fi; #removing unnecessary coma
  if (Size(preimgs) > 1) or (preimgs[1] <> point and not (preimgs[1] in cycle)) then 
    str := Concatenation(str,";"); 
  fi;
  str := Concatenation(str,StringPrint(point),"]"); # ending the tree notation
  return str;
end;




#Returns the linear notation of the transformation in a string
InstallGlobalFunction(LinearNotation,
 function(transformation)
local mapping,components,comp,cycle,point,str;
  if IsOne(transformation) then return "()";fi; #this special case would be difficult to handle
  #for the preimages
  mapping := SGPDEC_LinearNotation_Transformation2Mapping(transformation); 
  str := "";
  components := TransformationComponents(transformation);
  for comp in components do
    if Size(comp) = 1 then continue; fi;      #fixed points are not displayed
    cycle := CycleOfTransformationFromPoint(transformation,comp[1]); #1-cycles are not displayed as cycles (but it can be a tree)
    if (Length(cycle) > 1 ) then str := Concatenation(str,"(");fi;
    for point in cycle do
      if IsSubset(AsSet(cycle), AsSet(PreImages(mapping, point))) then 
        str := Concatenation(str,StringPrint(point));
      else
        str := SGPDEC_LinearNotation_TreePrint(point,mapping,cycle,str);
      fi;
      str := Concatenation(str,",");
    od;
    Remove(str);
    if (Length(cycle) > 1 ) then str := Concatenation(str,")");fi;
  od;
  return str;
end
);

#Returns the linear notation of the transformation in a string
InstallGlobalFunction(SimplerLinearNotation,
 function(transformation)
 if RankOfTransformation(transformation) = 1 then
  return Concatenation("[->", StringPrint(transformation![1][1]),"]");
 else
  return LinearNotation(transformation);
 fi; 
end
);

if LINEAR_NOTATION then
  #redefining display for transformations 
  InstallMethod( ViewObj,
    "linear notation for transformations",
    true,
    [IsTransformation], 0,
  function( t )
    Print(SimplerLinearNotation(t));
  end
  );
fi;
