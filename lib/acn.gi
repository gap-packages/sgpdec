################################################################################
##  SgpDec                        Attractor-cycle notation for transformations
##  Copyright (C) 2009-2024                             Attila Egri-Nagy et.al
################################################################################
# Functions only used here are prefixed by ACN.

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
  #p is repeated so we know where to cut out the cycle
  return orbit{[Position(orbit,p)..Length(orbit)]};
end);

################################################################################
# Recursively prints the tree incoming into a point. The point's cycle also
# needs to be known to exclude the preimages in the cycle.
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
  elif Size(preimgs) = 1 then #we do a belt
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
  else # we have choices
    str := Concatenation(str,"["); #starting the tree notation
    Sort(preimgs); # to get canonical form
    for p in preimgs do
      str := ACNTreePrint(p,t,cycle,str);
      str := Concatenation(str,"|");
    od;
    if Last(str) = '|' then Remove(str); fi; #removing unnecessary |
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

# constant maps are further simplified
# useful for diagram labels with many constant transformations
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

# It returns the sink of the expression, or nothing for a permutation.
# The important thing is the side-effect: collecting the individual maps.
# q - a queue storing the characters
# maps - utable list collecting pairs
ACNParse := function(q, maps)
  local digits, belt, RegisterBelt, choices, sink;
  RegisterBelt := function(belt) #registering the maps
    Perform([1..Size(belt)-1],
            function(i) Add(maps, [belt[i],belt[i+1]]);end);
  end;
  # getting a number ########################
  if IsDigitChar(PlistDequePeekFront(q)) then
    digits := [];
    while (IsDigitChar(PlistDequePeekFront(q))) do
      Add(digits, PopFront(q));
    od;
    return Int(digits);
  # building a permutation ##################
  elif '(' = PlistDequePeekFront(q) then
    PlistDequePopFront(q); #drop the opening paren
    if not (')' = PlistDequePeekFront(q)) then # in case of identity
      belt := [ACNParse(q,maps)];
      while (',' = PlistDequePopFront(q)) do
        #PlistDequePopFront(q); #drop the comma
        Add(belt, ACNParse(q,maps));
      od;
      Add(belt, First(belt)); #closing the cycle
      RegisterBelt(belt);
    else
      PlistDequePopFront(q); #drop the closing paren )
    fi;
  # building an inflow ##################
  elif '[' = PlistDequePeekFront(q) then
    PlistDequePopFront(q); #drop the opening paren
    belt := [ACNParse(q,maps)];
    # conveyor belt ######################
    if ',' = PlistDequePeekFront(q) then
      while (',' = PlistDequePopFront(q)) do
        Add(belt, ACNParse(q,maps));
      od;
      RegisterBelt(belt);
      return Last(belt);
    # choice #####################
    else
      choices := belt; #ok, we choices instead of a belt
      while ('|' = PlistDequePopFront(q)) do
        Add(choices, ACNParse(q,maps));
      od;
      #we hit the ,
      sink := ACNParse(q,maps);
      PlistDequePopFront(q); #drop the closing paren ]
      #register choices
      Perform(choices, function(i) Add(maps,[i,sink]);end);
      return sink;
    fi;
  fi;
end;
MakeReadOnlyGlobal("ACNParse");

# the main method for the conversion
# inputs: string and the degree of the resulting transformation
# the function crashes if the degree is smaller than needed
InstallOtherMethod(AsTransformation,
                   "for an attractor-cycle notation string and int",
                   [IsString,IsPosInt],
function(s,n)
local maps,t,m, q;
  maps := [];
  t := [1..n]; #identity is the default
  RemoveCharacters(s, " \n\t\r"); # sanitize TODO: this works with immutable strings, how?!
  q := PlistDeque(Size(s)); #the queue for parsing
  Perform(s, function(c) PushBack(q,c);end);
  #do all components
  while (fail <> PlistDequePeekFront(q)) do
    ACNParse(q,maps); # continue with the next component
  od;
  # patching the identity map with the collected maps
  for m in maps do t[m[1]] := m[2];od;
  return Transformation(t);
end);

###############################################################################
## VISUALIZATION ##############################################################
###############################################################################
InstallGlobalFunction(DotTransformation,
function(t)
  return DotDigraph(DigraphByEdges(List([1..DegreeOfTransformation(t)],
                                         i->[i,OnPoints(i,t)])));
end);

################################################################################
## TESTING #####################################################################
################################################################################
ACNTestFullTransformationSemigroup := function(n)
  return ForAll(FullTransformationSemigroup(n),
                t-> t=AsTransformation(AttractorCycleNotation(t),n));
end;
MakeReadOnlyGlobal("ACNTestFullTransformationSemigroup");

ACNTestRandomTransformation := function(n, rank)
  local t;
  t := RandomTransformation(n,rank);
  return t = AsTransformation(AttractorCycleNotation(t),n);
end;
MakeReadOnlyGlobal("ACNTestRandomTransformation");
