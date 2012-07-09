#############################################################################
###
##W  cascadeoperation.gi
##Y  Copyright (C) 2011-12  Attila Egri-Nagy, Chrystopher L. Nehaniv, and
##   James D. Mitchell
###
###  Licensing information can be found in the README file of this package.
###
##############################################################################
###
### Cascaded permutations and transformations.

##############################################################################
##############################################################################

##############################################################################
# gives the value of the action on the last coordinate by the given cascaded
# operation (the trick is that we give prefix coords)

SGPDEC_ActionOnLastCoord := function(coords, cascop)
  local depfuncval;
  # getting the value of the dependency function that acts on the last
  # coordinate
  depfuncval := cascop!.depfunc(coords{[1..(Length(coords)-1)]});

  #if it is a constant map (required for permutation reset automata)
  if IsTransformation(depfuncval) and RankOfTransformation(depfuncval)=1 then
    #the value of the constant transformation
    return depfuncval![1][1];
  fi;

  if coords[Length(coords)] = 0 then
    # TODO potential problem here when acting on 0 as a general transformation
    # may reduce the set
    return 0;
  fi;

  # ^ should be the right action
  return coords[Length(coords)] ^ depfuncval;
end;

##############################################################################
#applying the action for all the coordinate values

SGPDEC_CascadedAction := function(coords, cascop)
  return List([1..Size(coords)], x ->
   SGPDEC_ActionOnLastCoord(coords{[1..x]},cascop));
end;

##############################################################################
# for symbol printing prefixes

ConvertCascade2String := function(coordsprefix, converter)
local i,str;
  str := "";
  for i in [1..Length(coordsprefix)] do
    str := Concatenation(str,StringPrint(converter[i](coordsprefix[i])));
    if i < Length(coordsprefix) then str := Concatenation(str,","); fi;
  od;
  return str;
end;

##############################################################################
# this constructs the component action based on the flat action

ComponentActionForPrefix := function(cstr, flatoplist, prefix)
  local states, actionlist, level, src_int, dest_cs, coordval;

  states := States(cstr);
  actionlist := [];
  level := Length(prefix) + 1;

  #we need to augment the prefix with each  coordinate
  for coordval in StateSets(cstr)[level] do

    #augment (we change the argument prefix, but we change it back)
    Add(prefix, coordval);

    #pick one source cascaded state (the first in the interval may do)
    src_int := PositionCanonical(states,
                       Concretize(CascadedState(cstr, prefix)));

    #we find the cascaded state corresponding to the flatop image
    dest_cs := states[flatoplist[src_int]];

    # let's just record where did it go
    Add(actionlist,dest_cs[level]);

    #removing the last, getting back to the prefix
    Remove(prefix);
  od;

  if IsGroup(cstr[level]) then
    return PermList(actionlist);
  fi;
  return Transformation(actionlist);
end;

##############################################################################
##############################################################################

# for creating the identity cascaded permutation in a given family of cascaded
# product elements no dependencies, just the component's identtiy is returned

InstallGlobalFunction(IdentityCascadedOperation,
function(cstr)
  return DefineCascadedOperation(cstr,[]);
end);

# just creating random dependency functions
InstallGlobalFunction(RandomCascadedOperation,
function(cstr,numofdeps)
  local deps, level, arg;

  # sanity check, to avoid infinite loops down below
  if numofdeps > MaximumNumberOfElementaryDependencies(cstr) then
    numofdeps := MaximumNumberOfElementaryDependencies(cstr);
    Print("#W Number of elementary dependencies is set to ", numofdeps,
     "\n");
  fi;
  deps := [];

  # some trickry is needed as random may return the same element
  while Length(deps) <> numofdeps do
    level := Random(SgpDecOptionsRec.SGPDEC_RND, 1, Length(cstr));
    arg := Random(EnumeratorOfCartesianProduct(StateSets(cstr){[1..level-1]}));
    if not (arg in deps) then
      Add(deps,arg);
    fi;
  od;

  # now putting the actions there - this may still give identity and reduce the
  # number of dependencies
  deps := List(deps, arg -> [arg, Random(cstr[Length(arg)+1])]);

  return  DefineCascadedOperation(cstr,deps);
end);

# for creating cascade permutations by giving dependency function maps in a list
# of argument-value pairs (the default dependency function value is () )
# CAUTION! This uses the new DepFuncTable functionality!

InstallOtherMethod(DefineCascadedOperation, "for a cascaded structure and list",
[IsCascadedStructure, IsList],
function(cstr,pairs) local  pair, depfunctable;

  #creating new dependency function table
  depfunctable := [];
  #and just registering these new dependencies
  for pair in pairs do
    RegisterNewDependency(depfunctable,pair[1],pair[2]);
  od;

  return  CascadedOperation(cstr,depfunctable);
end
);

#for creating cascade permutations by giving dependency function maps in a
#dependency function table

InstallGlobalFunction(CascadedOperation,
function(cstr,depfunctable)
  local  depfunc, object;

  # a function that returns the value corresponding to the argument if found,
  # otherwise the identity - embedded function

  depfunc := function(args)
    local value;
    value := SearchDepFuncTable(depfunctable, args);
    if value <> fail then
      return value;
    fi;
    #returning identity based on the component
    return One(cstr[Length(args)+1]);
  end;

  return Objectify(CascadedOperationType,
                    rec(cstr:=cstr, depfunc:=depfunc));
end);

# the inverse of DefineCascadedOperation : returns a list containing
# coordinateprefixes - component element pairs (when it is not the identity of
# the component) note that this returns concrete states now

InstallGlobalFunction(DependencyMapsFromCascadedOperation,
function(cascop)
  local cstr, pairs, identity, value, i, coords;

  #getting reference to the cascaded object
  cstr := CascadedStructureOf(cascop);

  #pairs initialized
  pairs := [];
  for i in [1..Length(cstr)] do
    identity := One(cstr[i]);
    for coords in EnumeratorOfCartesianProduct(StateSets(cstr){[1..(i-1)]}) do
      value := cascop!.depfunc(coords);

      #if it is not the identity of the component
      if identity <> value then

        #then record the dependency map
        Add(pairs,[coords,value]);
      fi;
    od;
  od;
  return pairs;
end);

# simple trick for getting the inverse #TODO to be replaced by a real
# calculation

InstallOtherMethod(InverseOp, "for a cascaded perm",
[IsCascadedOperation],
function(cascperm)
  return BuildNC(CascadedStructureOf(cascperm),
                 Inverse(Collapse(cascperm)));
end);

# equality the worst case is when p and q are indeed equal, as every value is
# checked

InstallOtherMethod(\=, "for cascaded op and cascaded op", IsIdenticalObj,
[IsCascadedOperation, IsCascadedOperation],
function(p,q)
  local cstr, i, coords;

  #getting the family object
  cstr := CascadedStructureOf(p);

  for i in [1..Length(cstr)] do
    for coords in EnumeratorOfCartesianProduct(StateSets(cstr){[1..(i-1)]}) do
      if p!.depfunc(coords) <> q!.depfunc(coords) then
        return false;
      fi;
    od;
  od;
  return true;
end);

# comparison, less than, just a trick flattening and do the comparison there

InstallOtherMethod(\<, "for cascaded op and cascaded op",
[IsCascadedOperation, IsCascadedOperation],
function(p,q)
  return Collapse(p) < Collapse(q);
end);

InstallOtherMethod(OneOp, "for cascaded op",
[IsCascadedOperation],
function(co)
  return IdentityCascadedOperation(CascadedStructureOf(co));
end);

#multiplication of cascaded operations - it is a tricky one, since it just
#combines together the functions

InstallOtherMethod(\*, "multiplying cascaded operations", IsIdenticalObj,
[IsCascadedOperation, IsCascadedOperation],
function(p,q)
  local cstr, depfunct;

  #getting the info record as it contains the componentinfo
  cstr := CascadedStructureOf(p);

  # constructing the dependency function of acting by q on arguments premoved
  # by p one dependency function is enough for all levels

  depfunct := function(args)
  local  newargs;
    newargs := List([1..Length(args)],
     x-> SGPDEC_ActionOnLastCoord(args{[1..x]},p));

    # the product operation is the action of p on the arguments multiplied by
    # the action of q on the p-moved args
    return p!.depfunc(args) * q!.depfunc(newargs);
  end;

  return Objectify(CascadedOperationType,
                   rec(cstr:=cstr, depfunc:= depfunct));
end);

InstallOtherMethod(\^, "for cascaded operation and int",
[IsCascadedOperation, IsInt],
function(p, n)
  local result, multiplier, i;

  result := IdentityCascadedOperation(CascadedStructureOf(p));
  if n < 0 then
    multiplier := Inverse(p);
  else
    multiplier := p;
  fi;

  for i in [1..AbsoluteValue(n)] do
    result := result * multiplier;
  od;
  return result;
end);

# Implementing display, printing nice, human readable format.

InstallMethod( Display, "for a cascaded op",
[IsCascadedOperation],
function( co )
  local cstr, i, j;

  #getting the info record
  cstr := CascadedStructureOf(co);

  for i in [1..Length(cstr)] do
    Print("Level ",i,": ", cstr!.argument_names[i]," -> ",
     cstr!.names_of_components[i],"\n");
    for j in  (EnumeratorOfCartesianProduct( cstr!.state_sets{[1..(i-1)]} )) do
      if not IsOne(co![i](j)) then
        Print("[",ConvertCascade2String(j,cstr!.state_symbol_functions),
         "] -> ", cstr!.operation_symbol_functions[i](co![i](j)), "\n");
      fi;
    od;
    Print("\n");
  od;
end);

# Implementing viewobj, printing simple info.

InstallMethod(ViewObj, "displays a cascaded product operation",
[IsCascadedOperation],
function( co )
  Print("Cascaded operation in ", NameOf(CascadedStructureOf(co)));
end);

#applying a cascade operation to a cascade state
InstallOtherMethod(\^, "acting on cascaded states",
[IsAbstractCascadedState, IsCascadedOperation],
function(cs,co)
  return CascadedState(CascadedStructureOf(cs),SGPDEC_CascadedAction(cs,co));
end);

# YEAST for operations flattening - making an ordinary permutation out of the
# cascaded one the components are or dered then we do the enumeration then
# record as a transformation

# JDM this should be called AsTransformation or AsPermutation following the
# GAP convention that operations changing representations should be called
# AsSomething.

InstallMethod(Collapse, "flattens a cascaded operation",
[IsCascadedOperation],
function( co )
  local cstr, states, l, nstate, i;

  cstr:=CascadedStructureOf(co);
  states:=States(cstr);

  #l is the big list for the action
  l := [];

  #going through all possible coordinates and see where they go
  for i in [1..Size(states)] do
    #getting the new state
    nstate := SGPDEC_CascadedAction(states[i], co);
    Add(l, Position(states,nstate));
  od;

  #now creating a permutation or transformation out of l
  if cstr!.groupsonly then
    return PermList(l);
  fi;
  return Transformation(l);
end);

#raising a permutation/transformation to its cascaded format
InstallOtherMethod(BuildNC, "for a cascaded structure and object",
[IsCascadedStructure, IsObject],
function(cstr,flatop)
  local flatoplist, dependencies, prefixes, action, level, prefix;

  #getting  the images in a list ( i -> flatoplist[i] )
  flatoplist := OnTuples([1..Size(States(cstr))], flatop);

  dependencies := [];

  #enumerate prefixes for all levels
  for level in [1..Length(cstr)] do
    prefixes := EnumeratorOfCartesianProduct(StateSets(cstr){[1..level-1]});
    for prefix in prefixes do
      action := ComponentActionForPrefix(cstr, flatoplist, prefix);
      if action <> One(cstr[level]) then
         Add(dependencies,[prefix,action]);
      fi;
    od;
  od;

  #after the recursion done we have the defining elementary dependencies
  return DefineCascadedOperation(cstr,dependencies);
end);

#raising a permutation/transformation to its cascaded format
#TODO!! to check whether the action is in the component

InstallOtherMethod(Build, "for a cascaded structure and obj",
[IsCascadedStructure,IsObject],
function(cstr, flatop)

  #if it is not compatible
  if not IsDependencyCompatible(cstr,flatop) then
    Error("usage: the second argument does not belong to the wreath product");
    return;
  fi;
  return BuildNC(cstr,flatop);
end);

# checks whether the target level depends on onlevel in cascop.  simply follows
# the definition and varies one level

InstallGlobalFunction(DependsOn,
function(cascop, targetlevel, onlevel)
  local cstr, args, value, arg, coord;

  #getting the cascaded structure of the operation
  cstr := CascadedStructureOf(cascop);

  #all possible arguments up to targetlevel-1
  args:=EnumeratorOfCartesianProduct(StateSets(cstr){[1..(targetlevel-1)]});

  #so we test for all arguments
  #TODO some optimization may be possible here, not to check any twice
  for arg in args do

    #remember the value
    value := cascop!.depfunc(arg);

    #now do the variations
    for coord in StateSets(cstr)[onlevel] do
      arg[onlevel] := coord;

      #if there is a change then we are done!
      if value <>  cascop!.depfunc(arg) then
        return true;
      fi;
    od;
  od;
  return false;
end);

# it creates the graph of actual dependencies for a cascaded operation

InstallGlobalFunction(DependencyGraph,
function(cascop)
  local cstr, graph, i, j;

  # getting the info record as it contains the componentinfo
  cstr := CascadedStructureOf(cascop);

  graph := [];

  # checking all directed pairs systematically
  for i in [2..Length(cstr)] do
    for j in [1..i-1] do
      if DependsOn(cascop,i,j) then
        Add(graph,[i,j]);
      fi;
    od;
  od;
  return AsSortedList(graph);
end);

# returns a list of levels where the given cascaded operation has non-trivial
# action(s).

InstallGlobalFunction(ProjectedScope,
function(cascop)
local pscope,level,prefix,cstr;

  #getting the info object
  cstr := CascadedStructureOf(cascop);

  #we suppose there is no action
  pscope := FiniteSet([],Length(cstr));

  for level in [1..Length(cstr)] do
    for prefix in
     EnumeratorOfCartesianProduct(cstr!.state_sets{[1..(level-1)]} ) do
      #if it is not the identity of the component
      if One(cstr[level]) <> (cascop![level](prefix)) then
        #then we have at least one here
        Add(pscope,level);
        #so we can leave the loop
        break; #JDM is this right? This only breaks out of the inner loop not
        # the outer loop and so this doesn't result in a value being returned
      fi;
    od;
  od;
  return pscope;
end);

#DEPENDENCY COMPATIBILITY##

# a permutation/transformation is compatible with the dependency frame of a
# cascaded structure if the dependency relation is well-defined/single-valued,
# a function (i.e. there is a unique action for an abstract state (a prefix))
# the action is not checked here though

InstallGlobalFunction(IsDependencyCompatibleOnPrefix,
function(cstr, flatoplist, prefix)
  local states, src_int, dest_cs, dest_prefix, coords, postfix, i;

  states := States(cstr);

  #pick one source cascaded state (the first in the interval may do)
  src_int := PositionCanonical(states,Concretize(CascadedState(cstr, prefix)));

  #as a cascaded state the image is
  dest_cs := states[flatoplist[src_int]];

  #get the prefix out of it
  dest_prefix := dest_cs{[1..Length(prefix)]};

  #now checking: any image should have the same prefix
  #for all possible concretization
  for postfix in EnumeratorOfCartesianProduct(
   StateSets(cstr){[Length(prefix)+1..Length(cstr)]}) do
    coords := ShallowCopy(prefix);
    Append(coords,postfix);
    for i in [1..Length(dest_prefix)] do
      if dest_prefix[i]<>states[flatoplist[PositionCanonical(states,
       CascadedState(cstr,coords))]][i] then
        return false;
      fi;
    od;
  od;
  return true;
end);

# this function checks whether a permutation or a transformation is dependency
# compatible with a cascaded structure this checks all prefixes (abstract
# states) the flat operation should have degree equal to the number of cascaded
# states

InstallGlobalFunction(IsDependencyCompatible,
function(cstr,flatop)
   local flatoplist, prefixes, level, prefix;

  #converting the flat operation to a transformation list
  flatoplist := OnTuples([1..Size(States(cstr))], flatop);

  #enumerate prefixes for all levels
  for level in [1..Length(cstr)] do
    prefixes := EnumeratorOfCartesianProduct(StateSets(cstr){[1..level-1]});
    for prefix in prefixes do
      if not IsDependencyCompatibleOnPrefix(cstr, flatoplist, prefix) then
        return false;
      fi;
    od;
  od;
  return true;
end);

# returning parent cascaded structure

InstallMethod(CascadedStructureOf, "for a cascaded operation",
[IsCascadedOperation],
function(cascop)
  return cascop!.cstr;
end);

# drawing

InstallGlobalFunction(DotCascadedOperation,
function(co)
  local castruct, str, out, vertices, vertexlabels, edges, deps, coordsname,
  level, newnn, edge, i, dep, coord;

  castruct := CascadedStructureOf(co);

  str := "";
  out := OutputTextString(str,true);

  PrintTo(out,"digraph cascop{\n");

  #putting an extra node on the top as the title of the graph
  #AppendTo(out,"orig [label=\"", params.title ,"\",color=\"white\"];\n");
  #AppendTo(out,"orig -> n [style=\"invis\"];\n");

  #hashtables for storing string-string pairs
  vertices := [];

  #JDM no hash table!
  vertexlabels := HTCreate("a string");
  edges := [];

  #extracting dependencies
  deps := DependencyMapsFromCascadedOperation(co);
  coordsname := "n";
  Add(vertices, coordsname);

  #adding a default label
  HTAdd(vertexlabels,coordsname ," [width=0.2,height=0.2,label=\"\"]");

  #just to be on the safe side
  Sort(vertices); Sort(edges);

  for dep in deps do
    #coordsnames are created like n_#1_#2_...._#n
    coordsname := "n";
    level := 1;
    for coord in dep[1] do
      newnn := Concatenation(coordsname,"_",StringPrint(coord));
      edge := Concatenation(coordsname ," -> ", newnn," [label=\"",
       StringPrint(castruct!.state_symbol_functions[level](coord)),"\"]");

      if not (edge in edges) then

        # we just add the full edge
        Add(edges,edge, PositionSorted(edges,edge));
      fi;

      #we can now forget about the
      coordsname := newnn;
      level := level + 1;
      if not (coordsname in vertices) then
        i := PositionSorted(vertices, coordsname);
        Add(vertices, coordsname, i);
        #adding a default label
        HTAdd(vertexlabels, coordsname, " [width=0.2,height=0.2,label=\"\"]");
      fi;
    od;

    #putting the proper label there as we are at the end of the coordinates
    HTUpdate(vertexlabels, coordsname, Concatenation(" [label=\"",
     StringPrint(castruct!.operation_symbol_functions[level](dep[2])),"\"]"));
  od;

  # finally writing them into the dot file
  for i in [1..Size(vertices)] do
    AppendTo(out, vertices[i]," ",HTValue(vertexlabels,vertices[i]),";\n");
  od;

  for edge in edges do
    AppendTo(out, edge,";\n");
  od;

  AppendTo(out,"}\n");
  CloseStream(out);
  return str;
end);
