#############################################################################
###
##W  cascadedtrans.gi
##Y  Copyright (C) 2011-12
##   Attila Egri-Nagy, Chrystopher L. Nehaniv, and James D. Mitchell
###
###  Licensing information can be found in the README file of this package.
###
##############################################################################
###

InstallGlobalFunction(CreateDependencyFunction, 
function(func, enum)
  local record;

  record:=rec(func:=func, enum:=enum);
  return Objectify(NewType(CollectionsFamily(FamilyObj(func[2])),
   IsDependencyFunc), record);
end);

#

InstallMethod(ViewObj, "for a dependency func",
[IsDependencyFunc],
function(x)
  Print("<dependency function>");
  return;
end);

#

InstallOtherMethod(\^, "for a tuple and dependency func",
[IsList, IsDependencyFunc],
function(tup, depfunc)
  local func, enum, i, pos;
  
  func:=depfunc!.func;
  enum:=depfunc!.enum;

  i:=Length(tup)+1;
  
  if not IsBound(enum[i]) then 
    return fail;
  fi;
  
  pos:=Position(enum[i], tup);
  
  if pos=fail then 
    return fail;
  fi;

  if not IsBound(func[i][pos]) then 
    return ();
  fi;
  return func[i][pos];
end);

# Cascaded permutations and transformations.

InstallGlobalFunction(CascadedTransformationNC,
function(coll, depfunc)
  local enum, tup, func, f, i, x;
 
  if IsListOfPermGroupsAndTransformationSemigroups(coll) then 
    coll:=DomainsOfCascadeProductComponents(coll);
  fi;

  enum:=EmptyPlist(Length(coll)+1);
  enum[1]:=[[]];
  
  tup:=[];
  
  for i in [1..Length(coll)-1] do 
    Add(tup, coll[i]);
    Add(enum, EnumeratorOfCartesianProduct(tup));
  od;

  func:=List(enum, x-> EmptyPlist(Length(x)));

  for x in depfunc do
    func[Length(x[1])+1][Position(enum[Length(x[1])+1], x[1])]:=x[2];
  od;

  f:=Objectify(CascadedTransformationType, rec());
  SetDomainOfCascadedTransformation(f, EnumeratorOfCartesianProduct(coll));
  SetComponentDomainsOfCascadedTransformation(f, coll);
  SetDependencyFunction(f, CreateDependencyFunction(func, enum));
  return f;
end);

#

InstallGlobalFunction(RandomCascadedTransformation,
function(list, numofdeps)
  local coll, enum, tup, func, len, x, j, k, f, i;

  if not IsListOfPermGroupsAndTransformationSemigroups(list) then 
    Error("insert meaningful error message,");
    return;
  fi;

  coll:=DomainsOfCascadeProductComponents(list); 
  
  # create the enumerator for the dependency func
  enum:=EmptyPlist(Length(coll)+1);
  enum[1]:=[[]];
  
  tup:=[];
  
  for i in [1..Length(coll)-1] do 
    Add(tup, coll[i]);
    Add(enum, EnumeratorOfCartesianProduct(tup));
  od;

  # create the function
  func:=List(enum, x-> EmptyPlist(Length(x)));
  len:=Sum(List(enum, Length));
  numofdeps:=Minimum([len, numofdeps]);

  x:=[1..len];
  for i in [1..numofdeps] do 
    j:=Random(x);
    RemoveSet(x, j);
    k:=1;
    while j>Length(enum[k]) do 
      j:=j-Length(enum[k]);
      k:=k+1;
    od;
    func[k][j]:=Random(list[k]);
  od;
 
  # create f
  f:=Objectify(CascadedTransformationType, rec());
  SetDomainOfCascadedTransformation(f, EnumeratorOfCartesianProduct(coll));
  SetComponentDomainsOfCascadedTransformation(f, coll);
  SetDependencyFunction(f, CreateDependencyFunction(func, enum));
  return f;
end);

#JDM install CascadedTransformation, check args are sensible.

#

InstallMethod(ViewObj, "for a cascaded transformation",
[IsCascadedTransformation],
function(f)
  local prefix, midfix, suffix, x;

  prefix:="<cascaded transformation on ";
  midfix:="";
  
  for x in ComponentDomainsOfCascadedTransformation(f) do 
    Append(midfix, String(x));
    Append(midfix, ", ");
  od;
  Remove(midfix, Length(midfix));
  Remove(midfix, Length(midfix));

  suffix:=">";

  Print(prefix);
  if Length(prefix)+Length(midfix)+Length(suffix)<=SizeScreen()[1] then
    Print(midfix);
  fi;
  Print(suffix);
  return;
end);

InstallMethod(PrintObj, "for a cascaded transformation",
[IsCascadedTransformation],ViewObj);

# old


################################################################################
####CONSTRUCTING CASCADED OPERATIONS############################################

#for creating cascade permutations by giving dependency function maps in a
#dependency function table

# returns a list containing
# coordinateprefix-component element pairs (when it is not the identity of
# the component) note that this returns concrete states now
# very simple brute force algorithm
InstallGlobalFunction(DependencyMapsFromCascadedTransformation,
function(ct)
local csh, pairs, identity, value, i, coords;
  #getting reference to the cascaded object
  csh := CascadeShellOf(ct);
  #pairs initialized
  pairs := [];
  #first doing the the top level
  value := ct!.depfunc([]);
  if value <> Identity(csh[1]) then
    Add(pairs,[[],value]);
  fi;
  #then the deeper levels
  for i in [2..Length(csh)] do
    identity := One(csh[i]);
    for coords in EnumeratorOfCartesianProduct(CoordValSets(csh){[1..(i-1)]}) do
      value := ct!.depfunc(coords);
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
InstallGlobalFunction(IdentityCascadedTransformation,
function(csh)
  return CascadedTransformation(csh,DependencyTable([]));
end);

# creating random dependency functions
# the number of nontrivial entries has to be specified
##############ALGORITHMS TO GET THE INVERSE####################################
# We have different algorithms here. The fastest is plugged in the real Inverse.

#simple trick for getting the inverse: take the flat inverse instead
#InvCascadedTransformationByYeast := function(cascperm)
#  return AsCascadedTransNC(CascadeShellOf(cascperm),
#                 Inverse(AsTransformation(cascperm)));
#end;
#MakeReadOnlyGlobal("InvCascadedTransformationByYeast");

# calculating the powers until inverse found, this is of course very slow
InvCascadedTransformationByPowers := function(cascperm)
local pow, id, prevpow;
  pow := cascperm;
  id := IdentityCascadedTransformation(CascadeShellOf(cascperm));
  repeat
    prevpow := pow;
    pow := pow * cascperm;
  until id = pow;
  return prevpow;
end;
MakeReadOnlyGlobal("InvCascadedTransformationByPowers");

# transform the argument of the dependency and invert the value
InvCascadedTransformationByDependencies := function(cascperm)
local invmaps, dep;

  invmaps := [];
  for dep in DependencyMapsFromCascadedTransformation(cascperm) do
    Add(invmaps,
        [List([1..Size(dep[1])],
              x-> dep[1][x]^(cascperm!.depfunc(dep[1]{[1..x-1]}))),
         Inverse(dep[2])
         ]);
  od;
  return CascadedTransformation(CascadeShellOf(cascperm),
                 DependencyTable(invmaps));
end;
MakeReadOnlyGlobal("InvCascadedTransformationByDependencies");

#here we just plug one algorithm in
InstallOtherMethod(InverseOp, "for a cascaded perm",
        [IsCascadedTransformation],InvCascadedTransformationByDependencies);


################################################################################
####REIMPLEMENTED OPERATIONS####################################################
# equality the worst case is when p and q are indeed equal, as every value is
# checked
InstallOtherMethod(\=, "for cascaded op and cascaded op", IsIdenticalObj,
[IsCascadedTransformation, IsCascadedTransformation],
function(p,q)
  local csh, i, coords;
  #getting the family object
  csh := CascadeShellOf(p);
  #first comparing the the top level
  if p!.depfunc([]) <> q!.depfunc([]) then
    return false;
  fi;
  #then the deeper levels
  for i in [2..Length(csh)] do
    for coords in EnumeratorOfCartesianProduct(CoordValSets(csh){[1..(i-1)]}) do
      if p!.depfunc(coords) <> q!.depfunc(coords) then
        return false;
      fi;
    od;
  od;
  return true;
end);

# comparison, less than, just a trick flattening and do the comparison there
InstallOtherMethod(\<, "for cascaded op and cascaded op",
[IsCascadedTransformation, IsCascadedTransformation],
function(p,q)
  return ImageListOfActionOnCoords(p) < ImageListOfActionOnCoords(q);
  #TODO!!! this can be faster by not doing it full!!!
end);

InstallOtherMethod(OneOp, "for cascaded op",
[IsCascadedTransformation],
function(ct)
  return IdentityCascadedTransformation(CascadeShellOf(ct));
end);

#multiplication of cascaded operations - it is a tricky one, since it just
#combines together the functions without building a dependency table
InstallOtherMethod(\*, "multiplying cascaded operations", IsIdenticalObj,
[IsCascadedTransformation, IsCascadedTransformation],
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

  return Objectify(CascadedTransformationType,
                   rec(csh:=csh, depfunc:= depfunct));
end);

InstallOtherMethod(\^, "exponent for cascaded operation",
[IsCascadedTransformation, IsInt],
function(p, n)
  local result, multiplier, i;

  result := IdentityCascadedTransformation(CascadeShellOf(p));
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
ConvertCoords2String := function(csh, coordsprefix)
local i,str;
  str := "";
  for i in [1..Length(coordsprefix)] do
    str := Concatenation(str,
                   String(CoordValConverter(csh,i)(coordsprefix[i])));
    if i < Length(coordsprefix) then str := Concatenation(str,","); fi;
  od;
  return str;
end;
MakeReadOnlyGlobal("ConvertCoords2String");

# Implementing display, printing nice, human readable format.
InstallMethod( Display, "for a cascaded op",
[IsCascadedTransformation],
function( ct )
local csh, i, coords, val;
  csh := CascadeShellOf(ct);
  for i in [1..Length(csh)] do
    #printing the function definition
    if i = 1 then #the top level is not a function application mathematically
      Print("#",i,": ", csh[i],"\n");
      #do the first level here
      val := ct!.depfunc([]);
      if not IsOne(val) then
        Print(CoordTransConverter(csh,i)(val),"\n");
      fi;
    else
      Print("#",i,": ",NameOfDependencyDomain(csh,i)," -> ",csh[i],"\n");
    fi;
    #looping all possible arguments and display if any
    for coords in EnumeratorOfCartesianProduct(CoordValSets(csh){[1..(i-1)]}) do
      val := ct!.depfunc(coords);
      if not IsOne(val) then
        Print("[",ConvertCoords2String(csh, coords),
              "] -> ", CoordTransConverter(csh,i)(val),"\n");
      fi;
    od;
  od;
end);

# Implementing viewobj, printing simple info.
#function(ct)
#  Print("Cascaded transformation in ", Name(CascadeShellOf(ct)));
#end);


InstallGlobalFunction(OnCoordinates,
function(coords, ct)
local depfuncvalues,i, ncoords;

  depfuncvalues := List([1..Size(coords)],
                        x->ct!.depfunc(coords{[1..x-1]}));
  ncoords := [];
  for i in [1..Size(coords)] do
    #if it is a constant map (required for permutation reset automata)
    if IsTransformation(depfuncvalues[i])
       and RankOfTransformation(depfuncvalues[i])=1 then
      #the value of the constant transformation
      ncoords[i] :=  1^depfuncvalues[i];#![1][1];
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
[IsList, IsCascadedTransformation], OnCoordinates);

################################################################################
# CASCADED TRANSFORMATION --> TRANSFORMATION, PERMUTATION HOMOMORPHISMS ########
InstallGlobalFunction(ImageListOfActionOnCoords,
function(cascdtrans)
local csh, states, l, nstate, i;

  csh:=CascadeShellOf(cascdtrans);
  states:=AllCoords(csh);
  #l is the big list for the action
  l := [];
  #going through all possible coordinates and see where they go
  for i in [1..Size(states)] do
    #getting the new state
    nstate := OnCoordinates(states[i],cascdtrans);
    Add(l, Position(states,nstate));
  od;
  return l;
end);

InstallOtherMethod(AsTransformation,
        "for cascaded transformation with no decomposition info",
[IsCascadedTransformation],
function(ct)
  return Transformation(ImageListOfActionOnCoords(ct));
end);

InstallOtherMethod(AsPermutation,
        "for cascaded permutation with no decomposition info",
[IsCascadedTransformation],
function(ct)
  #if IsCascadedGroupShell(csh) then TODO maybe check this, give warning
  return PermList(ImageListOfActionOnCoords(ct));
end);


#do the action on coordinates by a flat operation (list of images)
FlatActionOnCoordinates := function(csh, flatop, coords)
local src;
  #pick one source cascaded state (the first in the interval may do)
  src := PositionCanonical(AllCoords(csh),
                     Concretize(csh, coords));
  #we find the cascaded state corresponding to the flatop image
  return AllCoords(csh)[flatop[src]];
end;
MakeReadOnlyGlobal("FlatActionOnCoordinates");

##############################################################################
# this constructs the component action based on the flat action
ComponentActionForPrefix := function(csh, flatoplist, prefix)
  local actionlist, level, coordval;

  actionlist := [];
  level := Length(prefix) + 1;

  #we need to augment the prefix with each  coordinate
  for coordval in CoordValSets(csh)[level] do
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
MakeReadOnlyGlobal("ComponentActionForPrefix");

#raising a permutation/transformation to its cascaded format
# InstallOtherMethod(AsCascadedTransNC,
#         "for flat transformation/permutation",
# [IsMultiplicativeElement,IsCascadeShell],
# function(flatop,csh)
#   local flatoplist, dependencies, prefixes, action, level, prefix;
# 
#   #getting  the images in a list ( i -> flatoplist[i] )
#   flatoplist := OnTuples([1..Size(AllCoords(csh))], flatop);
# 
#   dependencies := [];
# 
#   #enumerate prefixes for all levels
#   for level in [1..Length(csh)] do
#     #hacking the fix for the upstream changes EnumeratorOfCartesianProduct
#     if level = 1 then
#       prefixes := [ [] ];
#     else
#       prefixes := EnumeratorOfCartesianProduct(CoordValSets(csh){[1..level-1]});
#     fi;
#     for prefix in prefixes do
#       action := ComponentActionForPrefix(csh, flatoplist, prefix);
#       if action <> One(csh[level]) then
#          Add(dependencies,[prefix,action]);
#       fi;
#     od;
#   od;
# 
#   #after the recursion done we have the defining elementary dependencies
#   return CascadedTransformation(csh,DependencyTable(dependencies));
# end);

#raising a permutation/transformation to its cascaded format
#TODO!! to check whether the action is in the component

# InstallOtherMethod(AsCascadedTrans, "for transformation/permutation",
# [IsMultiplicativeElement,IsCascadeShell],
# function(flatop,csh)
#   #if it is not compatible
#   if not IsDependencyCompatible(csh,flatop) then
#     Error("usage: the second argument does not belong to the wreath product");
#     return;
#   fi;
#   return AsCascadedTransNC(flatop,csh);
# end);
# 
################################################################################
##########DEPENDENCIES##########################################################

# checks whether the target level depends on onlevel in ct.  simply follows
# the definition and varies one level
InstallGlobalFunction(DependsOn,
function(ct, targetlevel, onlevel)
  local csh, args, value, arg, coord;

  #getting the cascade shell of the operation
  csh := CascadeShellOf(ct);
  #all possible arguments up to targetlevel-1
  args:=EnumeratorOfCartesianProduct(CoordValSets(csh){[1..(targetlevel-1)]});
  #so we test for all arguments
  #TODO some optimization may be possible here, not to check any twice
  for arg in args do
    #remember the value
    value := ct!.depfunc(arg);
    #now do the variations
    for coord in CoordValSets(csh)[onlevel] do
      arg[onlevel] := coord;
      #if there is a change then we are done!
      if value <>  ct!.depfunc(arg) then
        return true;
      fi;
    od;
  od;
  return false;
end);

# it creates the graph of actual dependencies for a cascaded operation
InstallGlobalFunction(DependencyGraph,
function(ct)
  local graph, i, j;

  graph := [];
  # checking all directed pairs systematically
  for i in [2..Length(CascadeShellOf(ct))] do
    for j in [1..i-1] do
      if DependsOn(ct,i,j) then
        Add(graph,[i,j]);
      fi;
    od;
  od;
  return AsSortedList(graph);
end);

# returns a list of levels where the given cascaded operation has non-trivial
# action(s).
InstallGlobalFunction(ProjectedScope,
function(ct)
local pscope,level,prefix,csh;

  #getting the info object
  csh := CascadeShellOf(ct);

  #we suppose there is no action
  pscope := FiniteSet([],Length(csh));

  for level in [1..Length(csh)] do
    for prefix in
     EnumeratorOfCartesianProduct(CoordValSets(csh){[1..(level-1)]} ) do
      #if it is not the identity of the component
      if One(csh[level]) <> (ct!.depfunc(prefix)) then
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

  states := AllCoords(csh);
  #get the prefix out of it
  dest_prefix := FlatActionOnCoordinates(csh, flatoplist, prefix)
                 {[1..Length(prefix)]};
  #now checking: any image should have the same prefix
  #for all possible concretization
  for postfix in EnumeratorOfCartesianProduct(
   CoordValSets(csh){[Length(prefix)+1..Length(csh)]}) do
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
  flatoplist := OnTuples([1..Size(AllCoords(csh))], flatop);

  #enumerate prefixes for all levels
  for level in [1..Length(csh)] do
    prefixes := EnumeratorOfCartesianProduct(CoordValSets(csh){[1..level-1]});
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
[IsCascadedTransformation],
function(ct)
  return ct!.csh;
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
                     CascadedTransformation(csh,DependencyTable([[prefix,g]])));
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
InstallGlobalFunction(DotCascadedTransformation,
function(ct)
  local csh, str, out, vertices, vertexlabels, edges, deps, coordsname,
        level, newnn, edge, i, dep, coord;

  csh := CascadeShellOf(ct);
  str := "";
  out := OutputTextString(str,true);
  PrintTo(out,"digraph ct{\n");
  #putting an extra node on the top as the title of the graph
  #AppendTo(out,"orig [label=\"", params.title ,"\",color=\"white\"];\n");
  #AppendTo(out,"orig -> n [style=\"invis\"];\n");

  vertices := [];
  vertexlabels := rec();#HTCreate("a string");
  edges := [];
  #extracting dependencies
  deps := DependencyMapsFromCascadedTransformation(ct);
  coordsname := "n";
  Add(vertices, coordsname);
  #adding a default label
  vertexlabels.(coordsname) := " [width=0.2,height=0.2,label=\"\"]";
  #just to be on the safe side
  Sort(vertices); Sort(edges);
  for dep in deps do
    #coordsnames are created like n_#1_#2_...._#n
    coordsname := "n";
    level := 1;
    for coord in dep[1] do
      newnn := Concatenation(coordsname,"_",String(coord));
      edge := Concatenation(coordsname ," -> ", newnn," [label=\"",
                      String(csh!.coordval_converters[level](coord)),
                      "\"]");
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
        vertexlabels.(coordsname) := " [width=0.2,height=0.2,label=\"\"]";
      fi;
    od;

    #putting the proper label there as we are at the end of the coordinates
    vertexlabels.(coordsname) := Concatenation(" [label=\"",
            String(csh!.coordtrans_converters[level](dep[2])),"\"]");
  od;
  # finally writing them into the dot file
  for i in [1..Size(vertices)] do
    AppendTo(out, vertices[i]," ",vertexlabels.(vertices[i]),";\n");
  od;
  for edge in edges do
    AppendTo(out, edge,";\n");
  od;
  AppendTo(out,"}\n");
  CloseStream(out);
  return str;
end);
