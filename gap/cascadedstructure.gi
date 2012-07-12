#############################################################################
##
## cascadedstructure.gi           SgpDec package
##
## Copyright (C) 2008-2012
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Each cascaded product needs a detailed type structure. Here are the tools
## needed for that task.

###UTIL FUNCTIONS FOR THE MAIN CONSTRUCTOR

# Constructing a short name for a component
# 1. If it has a name just return it.
# 2. For a group when the Small Group's Library allowed, then use that
# 3. Otherwise S_order for semigroups, G_order for groups
Name4Component := function(comp)
  if HasName(comp) then
    return Name(comp);
  fi;

  if IsGroup(comp) then
    if SgpDecOptionsRec.SMALL_GROUPS then
      return StructureDescription(comp);
    else
      return Concatenation("G",StringPrint(Order(comp)));
    fi;
  else
    return Concatenation("S",StringPrint(Size(comp)));
  fi;
end;

InstallMethod(IsCascadedGroup,[IsCascadedStructure],
cstr -> ForAll(cstr!.components, IsGroup));


# SIMPLIFIED CONSTRUCTOR
# calling the main with default identity functions
InstallOtherMethod(CascadedStructure,[IsList],
function(components)
local statesym, opsym, comp,gid;

  statesym := [];
  opsym := [];
  for comp in components do
     Add(statesym, x->x);
     Add(opsym, function(x)
       if IsTransformation(x) then
         return SimplerLinearNotation(x);
       else
         return x; fi;end);
  od;
  return CascadedStructure(components,statesym,opsym);
end);

#THE MAIN CONSTRUCTOR with all the possible arguments
InstallMethod(CascadedStructure,[IsList,IsList,IsList],
function(components,statesymbolfunctions,operationsymbolfunctions)
local cascprodinfo,prodname,i,str,result,state_set_sizes, groupsonly;

  #GENERATING THE NAME
  #deciding whether it is a group or not and set the name accordingly
  groupsonly :=  ForAll(components, IsGroup);
  if groupsonly then
    prodname := "G";
  else
    prodname := "S";
  fi;
  #concatenating component names
  Perform(components,
          function(c)
            prodname := Concatenation(prodname,"_", Name4Component(c));
          end);

  #BUILDING THE INFO RECORD
  #this is the main record containing information about the cascade product,
  #the initial values do not matter
  cascprodinfo := rec(
                      state_symbol_functions := statesymbolfunctions,
                      operation_symbol_functions := operationsymbolfunctions,
                      components := components,
                      name_of_product := prodname);

  #guessing the statesets of the original components
  cascprodinfo.state_sets := []; #TODO this will be replaced by LambdaDomain
  for i in components do
    if IsGroup(i) then
      Add(cascprodinfo.state_sets,MovedPoints(i));
    else
      Add(cascprodinfo.state_sets,
          [1..DegreeOfTransformation(Representative(i))]);
    fi;
  od;

  #calculating the maximal number of elementary dependencies
  state_set_sizes := List(cascprodinfo.state_sets, x-> Size(x));
  cascprodinfo.maxnum_of_dependency_entries :=
    Sum(List([1..Size(components)], x-> Product(state_set_sizes{[1..x-1]})));

  #constructing argumentnames (for display purposes)
  cascprodinfo.argument_names := [];
  cascprodinfo.argument_names[1] := "{}"; #the empty set
  str := "";
  for i in [2..Length(components)] do
      if i > 2 then str  := Concatenation(str, " x ");fi;
      str := Concatenation(str,StringPrint(Size(cascprodinfo.state_sets[i-1])));
      cascprodinfo.argument_names[i] := str;
  od;

  #creating cascade state typed states
  #GENERATING STATES
  cascprodinfo.states := EnumeratorOfCartesianProduct(cascprodinfo.state_sets);

  result :=  Objectify(CascadedStructureType,cascprodinfo);

  #making it immutable TODO this may not work
  cascprodinfo := Immutable(cascprodinfo);

  return result;
end);

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

#constructing monomial generators
InstallGlobalFunction(MonomialGenerators,
function(cstr)
local mongens, depth, compgen, gens, prefixes,prefix, newprefix, newprefixes,
      orbitreprs, orbits, orbit, orbrep, isgroup;

  prefixes := [ [] ]; #the top level
  mongens := [];
  orbitreprs := [];

  for depth in [1..Length(cstr)] do
    #getting the component generators
    gens := GeneratorsOfSemigroup(cstr[depth]);
    isgroup := IsGroup(cstr[depth]);

    #adding the entries to the current coordinate fragments
    for prefix in prefixes do
      for compgen in gens do
        Add(mongens,
            CascadedOperation(cstr,DependencyTable([[prefix,compgen]])));
      od;
    od;

    #getting the orbit reprs
    orbitreprs := [];
    if isgroup then
      Perform(Orbits(cstr[depth]),
              function(o) Add(orbitreprs,o[1]);end
              );
    else
      Perform(SingletonOrbits(cstr[depth]),
              function(o) Append(orbitreprs,o);end
              );
    fi;

    newprefixes := [];
    #extending all prefixes with the orbitreprs
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

#######################ACCESS METHODS#######################
InstallGlobalFunction(States,
function(castruct) return castruct!.states; end);

InstallGlobalFunction(StateSets,
function(castruct) return castruct!.state_sets; end);

InstallGlobalFunction(MaximumNumberOfElementaryDependencies,
function(castruct) return castruct!.maxnum_of_dependency_entries; end);

InstallGlobalFunction(NameOf,
function(castruct) return castruct!.name_of_product; end);

#this is a huge number even in small cases
InstallGlobalFunction(SizeOfWreathProduct,
function(castruct)
local order,j,i;
  #calculating the order of the cascaded state set
  order := 1;
  #j is the number of possible arguments on a given depth, i.e.\ the exponent
  j := 1;
  for i in [1..Size(castruct)] do
    order := order * (Size(castruct[i])^j);
    j := j * Size(StateSets(castruct)[i]);
  od;
  return order;
end);

#######################OLD METHODS#############################
# The size of the cascaded structure is the number components.
InstallMethod(Length,"for cascaded structures",true,[IsCascadedStructure],
function(castruct)
  return Length(castruct!.components);
end
);

# for accessing the list elements
InstallOtherMethod( \[\],
    "for cascaded structures",
    [ IsCascadedStructure, IsPosInt ],
function( castruct, pos )
return castruct!.components[pos];
end
);

#############################################################################
# Implementing Display, printing nice, human readable format.
InstallMethod( ViewObj,
    "displays a cascaded structure",
    true,
    [IsCascadedStructure], 0,
function( castr )
local s,i;
  s := "";
  for i in [1..Length(castr)] do
    Print(i," ", s, Size(StateSets(castr)[i])," ");
    ViewObj(castr[i]);
    Print("\n");
    s := Concatenation(s,"|-");
  od;
end);