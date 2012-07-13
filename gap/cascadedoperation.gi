#############################################################################
###
##W  cascadeoperation.gi
##Y  Copyright (C) 2011-12
##   Attila Egri-Nagy, Chrystopher L. Nehaniv, and James D. Mitchell
###
###  Licensing information can be found in the README file of this package.
###
##############################################################################
###
### Cascaded permutations and transformations.

################################################################################
####CONSTRUCTING CASCADED OPERATIONS############################################

#for creating cascade permutations by giving dependency function maps in a
#dependency function table
InstallGlobalFunction(CascadedOperation,
function(csh,depfunctable)
local  depfunc;
  # a function that returns the value corresponding to the argument if found,
  # otherwise the identity - embedded function
  depfunc := function(args)
    local value;
    value := SearchDepFuncTable(depfunctable, args);
    if value <> fail then
      return value;
    fi;
    #returning identity based on the component
    return One(csh[Length(args)+1]);
  end;
  #creating the instance
  return Objectify(CascadedOperationType,
                    rec(csh:=csh, depfunc:=depfunc));
end);

# returns a list containing
# coordinateprefix-component element pairs (when it is not the identity of
# the component) note that this returns concrete states now
# very simple brute force algorithm
InstallGlobalFunction(DependencyMapsFromCascadedOperation,
function(cascop)
local csh, pairs, identity, value, i, coords;
  #getting reference to the cascaded object
  csh := CascadeShellOf(cascop);
  #pairs initialized
  pairs := [];
  for i in [1..Length(csh)] do
    identity := One(csh[i]);
    for coords in EnumeratorOfCartesianProduct(StateSets(csh){[1..(i-1)]}) do
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

# for creating the identity cascaded permutation in a given family of cascaded
# product elements no dependencies, just the component's identtiy is returned
InstallGlobalFunction(IdentityCascadedOperation,
function(csh)
  return CascadedOperation(csh,DependencyTable([]));
end);

# creating random dependency functions
# the number of nontrivial entries has to be specified
InstallGlobalFunction(RandomCascadedOperation,
function(csh,numofdeps)
local deps, level, arg;

  # sanity check, to avoid infinite loops down below
  if numofdeps > MaximumNumberOfElementaryDependencies(csh) then
    numofdeps := MaximumNumberOfElementaryDependencies(csh);
    Print("#W Number of elementary dependencies is set to ", numofdeps,"\n");
  fi;

  deps := [];
  # some trickery is needed as random may return the same element
  while Length(deps) <> numofdeps do
    level := Random(SgpDecOptionsRec.SGPDEC_RND, 1, Length(csh));
    arg := Random(EnumeratorOfCartesianProduct(StateSets(csh){[1..level-1]}));
    if not (arg in deps) then
      Add(deps,arg);
    fi;
  od;

  # now putting the actions there - this may still give identity and reduce the
  # number of dependencies
  deps := List(deps, arg -> [arg, Random(csh[Length(arg)+1])]);

  return CascadedOperation(csh,DependencyTable(deps));
end);

##############ALGORITHMS TO GET THE INVERSE####################################
# We have different algorithms here. The fastest is plugged in the real Inverse.

#simple trick for getting the inverse: take the flat inverse instead
InvCascadedOperationByYeast := function(cascperm)
  return RaiseNC(CascadeShellOf(cascperm),
                 Inverse(Flatten(cascperm)));
end;
MakeReadOnlyGlobal("InvCascadedOperationByYeast");

# calculating the powers until inverse found, this is of course very slow
InvCascadedOperationByPowers := function(cascperm)
local pow, id, prevpow;
  pow := cascperm;
  id := IdentityCascadedOperation(CascadeShellOf(cascperm));
  repeat
    prevpow := pow;
    pow := pow * cascperm;
  until id = pow;
  return prevpow;
end;
MakeReadOnlyGlobal("InvCascadedOperationByPowers");

# transform the argument of the dependency and invert the value
InvCascadedOperationByDependencies := function(cascperm)
local invmaps, dep;

  invmaps := [];
  for dep in DependencyMapsFromCascadedOperation(cascperm) do
    Add(invmaps,
        [List([1..Size(dep[1])],
              x-> dep[1][x]^(cascperm!.depfunc(dep[1]{[1..x-1]}))),
         Inverse(dep[2])
         ]);
  od;
  return CascadedOperation(CascadeShellOf(cascperm),
                 DependencyTable(invmaps));
end;
MakeReadOnlyGlobal("InvCascadedOperationByDependencies");

#here we just plug one algorithm in
InstallOtherMethod(InverseOp, "for a cascaded perm",
        [IsCascadedOperation],InvCascadedOperationByDependencies);


################################################################################
####REIMPLEMENTED OPERATIONS####################################################
# equality the worst case is when p and q are indeed equal, as every value is
# checked
InstallOtherMethod(\=, "for cascaded op and cascaded op", IsIdenticalObj,
[IsCascadedOperation, IsCascadedOperation],
function(p,q)
  local csh, i, coords;
  #getting the family object
  csh := CascadeShellOf(p);
  for i in [1..Length(csh)] do
    for coords in EnumeratorOfCartesianProduct(StateSets(csh){[1..(i-1)]}) do
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
  return Flatten(p) < Flatten(q);
end);

InstallOtherMethod(OneOp, "for cascaded op",
[IsCascadedOperation],
function(co)
  return IdentityCascadedOperation(CascadeShellOf(co));
end);

#multiplication of cascaded operations - it is a tricky one, since it just
#combines together the functions without building a dependency table
InstallOtherMethod(\*, "multiplying cascaded operations", IsIdenticalObj,
[IsCascadedOperation, IsCascadedOperation],
function(p,q)
  local csh, depfunct;

  #getting the info record as it contains the componentinfo
  csh := CascadeShellOf(p);

  # constructing the dependency function of acting by q on arguments premoved
  # by p one dependency function is enough for all levels
  depfunct := function(args)
  local  newargs;
    newargs := OnCoordinates(args,p);
    # the product operation is the action of p on the arguments multiplied by
    # the action of q on the p-moved args
    return p!.depfunc(args) * q!.depfunc(newargs);
  end;

  return Objectify(CascadedOperationType,
                   rec(csh:=csh, depfunc:= depfunct));
end);

InstallOtherMethod(\^, "exponent for cascaded operation",
[IsCascadedOperation, IsInt],
function(p, n)
  local result, multiplier, i;

  result := IdentityCascadedOperation(CascadeShellOf(p));
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
# Implementing display, printing nice, human readable format.
InstallMethod( Display, "for a cascaded op",
[IsCascadedOperation],
function( co )
  local csh, i, j;

  #getting the info record
  csh := CascadeShellOf(co);

  for i in [1..Length(csh)] do
    Print("Level ",i,": ", csh!.argument_names[i]," -> ",
     csh!.names_of_components[i],"\n");
    for j in EnumeratorOfCartesianProduct(StateSets(csh){[1..(i-1)]}) do
      if not IsOne(co!.depfunc(j)) then
        Print("[",ConvertCascade2String(j,csh!.state_symbol_functions),
         "] -> ", csh!.operation_symbol_functions[i](co!.depfunc(j)), "\n");
      fi;
    od;
    Print("\n");
  od;
end);

# Implementing viewobj, printing simple info.

InstallMethod(ViewObj, "displays a cascaded product operation",
[IsCascadedOperation],
function( co )
  Print("Cascaded operation in ", Name(CascadeShellOf(co)));
end);

#applying a cascade operation to a cascade state
InstallGlobalFunction(OnCascadedStates,
function(cs,co)
  return CascadedState(CascadeShellOf(cs), OnCoordinates(cs,co));
end);

InstallGlobalFunction(OnCoordinates,
function(coords, cascop)
local depfuncvalues,i, ncoords;

  depfuncvalues := List([1..Size(coords)],
                        x->cascop!.depfunc(coords{[1..x-1]}));
  ncoords := [];
  for i in [1..Size(coords)] do
    #if it is a constant map (required for permutation reset automata)
    if IsTransformation(depfuncvalues[i])
       and RankOfTransformation(depfuncvalues[i])=1 then
      #the value of the constant transformation
      ncoords[i] :=  depfuncvalues[i]![1][1];
    elif coords[i] = 0 then
      #TODO potential problem here when acting on 0, i.e. the set of all states
      # since a general transformation may reduce the set
      ncoords[i] :=  0;
    else
      ncoords[i] := OnPoints(coords[i], depfuncvalues[i]);
    fi;
  od;
  return ncoords;
end);

InstallOtherMethod(\^, "acting on cascaded states",
[IsAbstractCascadedState, IsCascadedOperation], OnCascadedStates);


# YEAST for operations flattening - making an ordinary permutation out of the
# cascaded one the components are or dered then we do the enumeration then
# record as a transformation

# JDM this should be called AsTransformation or AsPermutation following the
# GAP convention that operations changing representations should be called
# AsSomething.

InstallOtherMethod(Flatten, "for cascaded operation with no decomposition info",
[IsCascadedOperation],
function( co )
  local csh, states, l, nstate, i;

  csh:=CascadeShellOf(co);
  states:=States(csh);

  #l is the big list for the action
  l := [];

  #going through all possible coordinates and see where they go
  for i in [1..Size(states)] do
    #getting the new state
    nstate := OnCoordinates(states[i],co);
    Add(l, Position(states,nstate));
  od;

  #now creating a permutation or transformation out of l
  if IsCascadedGroupShell(csh) then
    return PermList(l);
  fi;
  return Transformation(l);
end);

#do the action on coordinates by a flat operation (list of images)
FlatActionOnCoordinates := function(csh, flatop, coords)
local src;
  #pick one source cascaded state (the first in the interval may do)
  src := PositionCanonical(States(csh),
                     Concretize(CascadedState(csh, coords)));
  #we find the cascaded state corresponding to the flatop image
  return States(csh)[flatop[src]];
end;

##############################################################################
# this constructs the component action based on the flat action
ComponentActionForPrefix := function(csh, flatoplist, prefix)
  local actionlist, level, coordval;

  actionlist := [];
  level := Length(prefix) + 1;

  #we need to augment the prefix with each  coordinate
  for coordval in StateSets(csh)[level] do
    #augment (we change the argument prefix, but we change it back)
    Add(prefix, coordval);
    # let's just record where did it go
    Add(actionlist,FlatActionOnCoordinates(csh, flatoplist, prefix)[level]);
    #removing the last, getting back to the prefix
    Remove(prefix);
  od;

  if IsGroup(csh!.components[Size(prefix)+1]) then
    return PermList(actionlist);
  fi;
  return Transformation(actionlist);
end;

#raising a permutation/transformation to its cascaded format
#InstallOtherMethod(RaiseNC, "for a cascade shell and object",
#[IsCascadeShell, IsObject],
# for the time being just a function
InstallOtherMethod(RaiseNC, "for a flat transformation with no decomposition",
[IsCascadeShell,IsObject],
function(csh, flatop)
  local flatoplist, dependencies, prefixes, action, level, prefix;

  #getting  the images in a list ( i -> flatoplist[i] )
  flatoplist := OnTuples([1..Size(States(csh))], flatop);

  dependencies := [];

  #enumerate prefixes for all levels
  for level in [1..Length(csh)] do
    prefixes := EnumeratorOfCartesianProduct(StateSets(csh){[1..level-1]});
    for prefix in prefixes do
      action := ComponentActionForPrefix(csh, flatoplist, prefix);
      if action <> One(csh[level]) then
         Add(dependencies,[prefix,action]);
      fi;
    od;
  od;

  #after the recursion done we have the defining elementary dependencies
  return CascadedOperation(csh,DependencyTable(dependencies));
end);

#raising a permutation/transformation to its cascaded format
#TODO!! to check whether the action is in the component
InstallOtherMethod(Raise, "for a flat transformation with no decomposition",
[IsCascadeShell,IsObject],
function(csh, flatop)
  #if it is not compatible
  if not IsDependencyCompatible(csh,flatop) then
    Error("usage: the second argument does not belong to the wreath product");
    return;
  fi;
  return RaiseNC(csh,flatop);
end);

################################################################################
##########DEPENDENCIES##########################################################

# checks whether the target level depends on onlevel in cascop.  simply follows
# the definition and varies one level
InstallGlobalFunction(DependsOn,
function(cascop, targetlevel, onlevel)
  local csh, args, value, arg, coord;

  #getting the cascade shell of the operation
  csh := CascadeShellOf(cascop);
  #all possible arguments up to targetlevel-1
  args:=EnumeratorOfCartesianProduct(StateSets(csh){[1..(targetlevel-1)]});
  #so we test for all arguments
  #TODO some optimization may be possible here, not to check any twice
  for arg in args do
    #remember the value
    value := cascop!.depfunc(arg);
    #now do the variations
    for coord in StateSets(csh)[onlevel] do
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
  local graph, i, j;

  graph := [];
  # checking all directed pairs systematically
  for i in [2..Length(CascadeShellOf(cascop))] do
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
local pscope,level,prefix,csh;

  #getting the info object
  csh := CascadeShellOf(cascop);

  #we suppose there is no action
  pscope := FiniteSet([],Length(csh));

  for level in [1..Length(csh)] do
    for prefix in
     EnumeratorOfCartesianProduct(StateSets(csh){[1..(level-1)]} ) do
      #if it is not the identity of the component
      if One(csh[level]) <> (cascop!.depfunc(prefix)) then
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
# cascade shell if the dependency relation is well-defined/single-valued,
# a function (i.e. there is a unique action for an abstract state (a prefix))
# the action is not checked here though TODO!!!!
InstallGlobalFunction(IsDependencyCompatibleOnPrefix,
function(csh, flatoplist, prefix)
  local states, dest_prefix, coords, postfix, i;

  states := States(csh);
  #get the prefix out of it
  dest_prefix := FlatActionOnCoordinates(csh, flatoplist, prefix)
                 {[1..Length(prefix)]};
  #now checking: any image should have the same prefix
  #for all possible concretization
  for postfix in EnumeratorOfCartesianProduct(
   StateSets(csh){[Length(prefix)+1..Length(csh)]}) do
    coords := ShallowCopy(prefix);
    Append(coords,postfix);
    for i in [1..Length(dest_prefix)] do
      if dest_prefix[i] <>
         FlatActionOnCoordinates(csh, flatoplist, coords)[i] then
        return false;
      fi;
    od;
  od;
  return true;
end);

# this function checks whether a permutation or a transformation is dependency
# compatible with a cascade shell this checks all prefixes (abstract
# states) the flat operation should have degree equal to the number of cascaded
# states

InstallGlobalFunction(IsDependencyCompatible,
function(csh,flatop)
   local flatoplist, prefixes, level, prefix;

  #converting the flat operation to a transformation list
  flatoplist := OnTuples([1..Size(States(csh))], flatop);

  #enumerate prefixes for all levels
  for level in [1..Length(csh)] do
    prefixes := EnumeratorOfCartesianProduct(StateSets(csh){[1..level-1]});
    for prefix in prefixes do
      if not IsDependencyCompatibleOnPrefix(csh, flatoplist, prefix) then
        return false;
      fi;
    od;
  od;
  return true;
end);

# returning parent cascade shell
InstallMethod(CascadeShellOf, "for a cascaded operation",
[IsCascadedOperation],
function(cascop)
  return cascop!.csh;
end);


################################################################################
######MONOMIAL GENERATORS#######################################################

# MonomialGenerators require the orbits of singletons under semigroup action
SingletonOrbits := function(T)
local i, sets,o;
    sets := [];
    for i in [1..DegreeOfTransformationSemigroup(T)] do
      o := Orb(T,i, OnPoints);
      Enumerate(o);
      AddSet(sets,AsSortedList(o));
    od;
    return sets;
end;
MakeReadOnlyGlobal("SingletonOrbits");

#constructing monomial generators for the wreath product
#on each level for each path of a component orbit representative we
#put the component generators
InstallGlobalFunction(MonomialWreathProductGenerators,
function(csh)
local mongens, depth, compgen, gens, prefixes,prefix, newprefix, newprefixes,
      orbitreprs, orbits, orbit, orbrep;

  prefixes := [ [] ]; #the top level
  mongens := [];

  for depth in [1..Length(csh)] do
    #getting the component generators
    gens := GeneratorsOfSemigroup(csh[depth]);

    #adding dependencies to coordinate fragments (prefixes) on current level
    for prefix in prefixes do
      Perform(gens,
              function(g)
                 Add(mongens,
                     CascadedOperation(csh,DependencyTable([[prefix,g]])));
               end);
    od;

    #getting the orbit reprs on level
    orbitreprs := [];
    if IsGroup(csh[depth]) then
      Perform(Orbits(csh[depth]),
              function(o) Add(orbitreprs,o[1]);end
              );
    else
      Perform(SingletonOrbits(csh[depth]),
              function(o) Append(orbitreprs,o);end
              );
    fi;

    #extending all prefixes with the orbitreprs on level
    newprefixes := [];
    for prefix in prefixes do
      for orbrep in orbitreprs do
        #the extension
        newprefix := ShallowCopy(prefix);
        Add(newprefix, orbrep);
        Add(newprefixes, newprefix);
      od;
    od;
    prefixes := newprefixes;
  od;
  return mongens;
end);

################################################################################
########### DRAWING ############################################################
InstallGlobalFunction(DotCascadedOperation,
function(co)
  local castruct, str, out, vertices, vertexlabels, edges, deps, coordsname,
  level, newnn, edge, i, dep, coord;

  castruct := CascadeShellOf(co);

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