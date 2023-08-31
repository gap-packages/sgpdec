##########################################################################
##
## linearnotation.gi           SgpDec package
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## 2009-2012, 2023
## One line notation for transformations.

################################################################################
# TRANSFORMATION -> LINEAR NOTATION ############################################
################################################################################

DotTransformation:=function(t)
  return DotDigraph(DigraphByEdges(List([1..DegreeOfTransformation(t)],
                                         i->[i,OnPoints(i,t)])));
end;
MakeReadOnlyGlobal("DotTransformation");

# Finding the components of a transformation, i.e.  the disconnected subgraphs
# of its functional digraph.
# A component is a list of points, and the components are returned in a list.
TransformationComponents := function(t)
  return DigraphConnectedComponents(
            DigraphByEdges(List([1..DegreeOfTransformation(t)],
            i->[i,OnPoints(i,t)]))).comps;
end;
MakeReadOnlyGlobal("TransformationComponents");

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
MakeReadOnlyGlobal("CycleOfTransformationFromPoint");

################################################################################
# Recursively prints the tree incoming into a point. The point's cycle also
# needs to be known to exclude tho preimages in the cycle.
# point - the root of the tree,
# t - transformation,
# cycle - the cycle of the component
# str - the buffer string in which to print
TreePrint := function(point, t,cycle, str)
local preimgs,p, conveyorbelt,s;
  #we reverse the arrows in the graph for the recursion, but not the cycle
  preimgs := Difference(PreimagesOfTransformation(t, point),cycle);
  if IsEmpty(preimgs) then   #if it is a terminal point, just print it
    str := Concatenation(str,String(point));
    return str;
  elif Size(preimgs) = 1 then
    conveyorbelt := [];
    while Size(preimgs) = 1 do
      Add(conveyorbelt,preimgs[1]);
      preimgs := Difference(PreimagesOfTransformation(t, preimgs[1]),cycle);
    od;
    str := Concatenation(str,"["); #starting the tree notation
    str := TreePrint(Remove(conveyorbelt),t,cycle,str);
    str := Concatenation(str,",");
    s := String(Reversed(conveyorbelt));
    RemoveCharacters(s," ");
    if Size(s) > 2 then str := Concatenation(str, s{[2..Size(s)-1]},",");fi;
    str := Concatenation(str,String(point),"]"); # ending the tree notation
  else
    str := Concatenation(str,"["); #starting the tree notation
    Sort(preimgs); # to get canonical form
    for p in preimgs do
      str := TreePrint(p,t,cycle,str);
      str := Concatenation(str,"|");
    od;
    if str[Length(str)] = '|' then Remove(str); fi; #removing unnecessary | 
    str := Concatenation(str,",");
    str := Concatenation(str,String(point),"]"); # ending the tree notation
  fi;
  return str;
end;
MakeReadOnlyGlobal("TreePrint");

#Returns the linear notation of the transformation in a string
InstallGlobalFunction(AttractorCycleNotation,
function(t)
  local comp,cycle,point,str;
  #this special case would be difficult to handle
  if IsOne(t) then return "()";fi;
  if IsPerm(t) then return PrintString(t); fi;
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
InstallGlobalFunction(SimplerAttractorCycleNotation,
 function(t)
 if IsTransformation(t) and RankOfTransformation(t) = 1 then
  return String(1^t);
 else
  return AttractorCycleNotation(t);
 fi;
end);

#redefining display for transformations if user
#wants the attractor-cycle notation
if SgpDecOptionsRec.ATTRACTOR_CYCLE_NOTATION then
  InstallMethod( ViewObj,
    "attractor-cycle notation for transformations",
    true,
    [IsTransformation], 0,
  function(t)
    Print(AttractorCycleNotation(t));
  end);
fi;

################################################################################
# ATTRACTOR-CYCLE NOTATION -> TRANSFORMATION ###################################
################################################################################

# assigns how many parentheses are open to each point, 0 means top level
DepthVector := function(str)
local openers,closers,depth,i,depthvect;
  openers := "[(";
  closers := ")]";
  depth := 0;
  depthvect := EmptyPlist(Size(str));
  for i in [1..Size(str)] do
    if str[i] in openers then
      depth := depth + 1;
    elif str[i] in closers then
      depth := depth - 1;
    fi;
    depthvect[i]:= depth;
  od;
  return depthvect;
end;
MakeReadOnlyGlobal("DepthVector");

#splitting string at given positions #TODO this is not splitting the last one, but works ok in the context as the last index is given
SplitStringAtPositions := function(str, poss)
  local pieces, last,i;
  last := 0;
  pieces := [];
  for i in [1..Size(poss)] do
    Add(pieces, str{[last+1..poss[i]]});
    last := poss[i];
  od;
  return pieces;
end;
MakeReadOnlyGlobal("SplitStringAtPositions");

# finding comma separated values (only at zero depth)
CommaComps := function(str)
  local cuts;
  if IsEmpty(str) then return [];fi;
  cuts := Intersection(Positions(DepthVector(str),0),
                  Positions(str,','));
  Add(cuts, Size(str)); #to have the last pieve as well
  #post process: removing dangling commas
  return List(SplitStringAtPositions(str, cuts),
              function(s) if s[Size(s)]=',' then return s{[1..Size(s)-1]};
                          else return s; fi;end);
end;
MakeReadOnlyGlobal("CommaComps");

#just remove outer parentheses
CutParentheses := function(str) return str{[2..Size(str)-1]}; end;
MakeReadOnlyGlobal("CutParentheses");

#this gets the last image from w or [x,y,z;w]
GetImgVal := function(str)
local s, poss, lastpos;
  if not('[' in str)  then return str;
  else
    s := CutParentheses(str);
    poss := Positions(str, ';');
    lastpos := poss[Size(poss)];
    return s{[lastpos..Size(s)]};
  fi;
end;
MakeReadOnlyGlobal("GetImgVal");

#this gets the preimages [x,y,z] from [x,y,z;w]
GetPreImgs := function(str)
local s, poss, lastpos;
    s := CutParentheses(str);
    poss := Positions(str, ';');
    lastpos := poss[Size(poss)];
    return CommaComps(s{[1..lastpos-2]});
end;
MakeReadOnlyGlobal("GetPreImgs");

#recursively fills the list maps [point, image] tuples
AllMaps := function(str,maps)
  local l,i,comps,img;
  comps := [];
  if str[1] = '(' then      # permutation
    comps := CommaComps(CutParentheses(str));
    l := List(comps, s->Int(GetImgVal(s)));
    if not IsEmpty(l) then Add(l, l[1]);fi; #closing the circle
    for i in [1..Size(l)-1] do
      Add(maps, [l[i],l[i+1]]);
    od;
  elif str[1] = '[' then     # transformation
    comps := (GetPreImgs(str));
    l := List(comps, s->Int(GetImgVal(s)));
    img := Int(GetImgVal(str));
    Perform([1..Size(l)], function(x)Add(maps,[l[x],img]);end);
  fi;
  #doing the recursion
  Perform(comps,function(x)AllMaps(x,maps);end);
  return maps;
end;
MakeReadOnlyGlobal("AllMaps");

# the main method for the conversion
InstallOtherMethod(AsTransformation,"for cascade and int",[IsString,IsPosInt],
function(s,n)
local maps,scc,l,m;
  maps := [];
  l := [1..n];
  for scc in SplitStringAtPositions(s, Positions(DepthVector(s),0)) do
    AllMaps(scc,maps);
  od;
  # patching the identity map with the collected maps
  for m in maps do l[m[1]] := m[2];od;
  return Transformation(l);
end);
