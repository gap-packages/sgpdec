################################################################################
##  SgpDec                        Attractor-cycle notation for transformations
##  Copyright (C) 2009-2024                             Attila Egri-Nagy et.al
################################################################################

###############################################################################
# TRANSFORMATION -> ATTRACTOR-CYCLE NOTATION ##################################
###############################################################################

# Find the points in the cycle in a component containing the initial point.
# It terminates with the first repeated point.
InstallGlobalFunction(CycleOfTransformationFromPoint,
function(t,p)
local orbit;
  orbit := []; #we generate the orbit
  while not (p in orbit) do
    Add(orbit,p);
    p := p ^ t;
  od;
  #p is repeated so we can  cut out the cycle
  return orbit{[Position(orbit,p)..Length(orbit)]};
end);

################################################################################
# Recursively prints the tree incoming into a point. The point's cycle also
# needs to be known to exclude tho preimages in the cycle.
# point - the root of the tree,
# t - transformation,
# cycle - the cycle of the component
# str - the buffer string in which to print
ACNTreePrint := function(point, t,cycle, str)
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
    str := ACNTreePrint(Remove(conveyorbelt),t,cycle,str);
    str := Concatenation(str,",");
    s := String(Reversed(conveyorbelt));
    RemoveCharacters(s," ");
    if Size(s) > 2 then str := Concatenation(str, s{[2..Size(s)-1]},",");fi;
    str := Concatenation(str,String(point),"]"); # ending the tree notation
  else
    str := Concatenation(str,"["); #starting the tree notation
    Sort(preimgs); # to get canonical form
    for p in preimgs do
      str := ACNTreePrint(p,t,cycle,str);
      str := Concatenation(str,"|");
    od;
    if str[Length(str)] = '|' then Remove(str); fi; #removing unnecessary | 
    str := Concatenation(str,",");
    str := Concatenation(str,String(point),"]"); # ending the tree notation
  fi;
  return str;
end;
MakeReadOnlyGlobal("ACNTreePrint");

#Returns the linear notation of the transformation in a string
InstallGlobalFunction(AttractorCycleNotation,
function(t)
  local comp,cycle,point,str;
  #this special case would be difficult to handle
  if IsOne(t) then return "()";fi;
  if IsPerm(t) then return PrintString(t); fi;
  str := "";
  for comp in ComponentsOfTransformation(t) do
    if Size(comp) = 1 then continue; fi;#fixed points are not displayed
    #1-cycles are not displayed as cycles (but it can be a tree)
    cycle := CycleOfTransformationFromPoint(t,First(comp));
    if (Length(cycle) > 1) then #if it is a permutation
      str := Concatenation(str,"(");
    fi;
    for point in cycle do
      str := ACNTreePrint(point,t,cycle,str);
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
# when generating the maps we go down recursively, this is used to find the right level
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

#splitting string at given positions
InstallGlobalFunction(SplitStringAtPositions,
function(str, positions)
  local poss;
  #adding the beginning and the end to the cutting positions
  poss := Set(Concatenation(positions,[0,Size(str)]));
  #producing the pieces
  return List([1..Size(poss)-1],
              x -> str{[poss[x]+1..poss[x+1]]});
end);

# components of the transformation, the strongly connected components of the graph
ACNComponents := function(s)
  return SplitStringAtPositions(s, Positions(DepthVector(s),0));
end;

# we cannot by all separators , and |, only on top level
ACNTopLevelCuts := function(str)
  return Intersection(Positions(DepthVector(str),0),
                      Union(Positions(str,','),
                            Positions(str,'|')));
end;

# the components of an in-flow
ACNInFlowComps := function(str)
  #post process: removing dangling commas
  return List(SplitStringAtPositions(str, ACNTopLevelCuts(str)),
              function(s) if Last(s) in ",|" then
                            return s{[1..Size(s)-1]};
                          else
                            return s; fi;
                          end);
end;
MakeReadOnlyGlobal("ACNInFlowComps");

#just remove outer parentheses
ACNCutParentheses := function(str) return str{[2..Size(str)-1]}; end;
MakeReadOnlyGlobal("ACNCutParentheses");

#this gets the last point w from [x,y,z,w] or [x|y|z,w], where everything is flowing into
ACNSink := function(str)
  if not('[' in str)  then
    return Int(str);
  else
    return ACNSink(Last(ACNInFlowComps(ACNCutParentheses(str))));
  fi;
end;
MakeReadOnlyGlobal("ACNSink");

#recursively fills the list maps [point, image] tuples
ACNAllMaps := function(str,maps)
  local i,comps,img, compswithseps, cut, spread, belt, NotSep, RegisterBelt;
  NotSep := function(s) return not( (s = ",") or (s = "|")); end;
  RegisterBelt := function(belt) #registering the maps
                    Perform([1..Size(belt)-1],
                            function(i) Add(maps, [belt[i],belt[i+1]]);end);
                  end;
  comps := ACNInFlowComps(ACNCutParentheses(str));
  if str[1] = '(' then      # permutation
    belt := List(comps, ACNSink);
    if not IsEmpty(belt) then Add(belt, First(belt));fi; #closing the cycle
    RegisterBelt(belt);
  elif str[1] = '[' then     # in-flow
    compswithseps := ACNComponents(ACNCutParentheses(str));
    if not ("|" in compswithseps) then
      RegisterBelt(List(comps, ACNSink));
    else # we have the |, so we have the spread of alternatives
      cut := First(Positions(compswithseps,","));
      spread := List(Filtered(compswithseps{[1..cut]}, NotSep), ACNSink);
      belt := List(Filtered(compswithseps{[cut+1..Size(compswithseps)]},NotSep), ACNSink);
      img := First(belt);
      Perform(spread, function(x)Add(maps,[x,img]);end);
      RegisterBelt(belt);
    fi;
  else
    return maps; #we are down to a point, nothing to do
  fi;
  #doing the recursion
  Perform(comps,function(x)ACNAllMaps(x,maps);end);
  return maps;
end;
MakeReadOnlyGlobal("ACNAllMaps");

# the main method for the conversion
# inputs: string and the degree of the resulting transformation
# the function crashes if the degree is smaller than needed
InstallOtherMethod(AsTransformation,"for an attractor-cycle notation string and int",[IsString,IsPosInt],
function(s,n)
local maps,scc,l,m;
  maps := [];
  l := [1..n]; #identity is the default
  Perform(ACNComponents(s), function(C) ACNAllMaps(C, maps);end);
  # patching the identity map with the collected maps
  for m in maps do l[m[1]] := m[2];od;
  return Transformation(l);
end);

###############################################################################
## VISUALIZATION ##############################################################
###############################################################################
InstallGlobalFunction(DotTransformation,
function(t)
  return DotDigraph(DigraphByEdges(List([1..DegreeOfTransformation(t)],
                                         i->[i,OnPoints(i,t)])));
end);
