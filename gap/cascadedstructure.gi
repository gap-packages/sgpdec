#############################################################################
##
## cascadedstructure.gi           SgpDec package
##
## Copyright (C) Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## 2008-2012
##
## Each cascaded product needs a detailed type structure. Here are the tools
## needed for that task.

#just the identity function
SGPDEC_idfunct := function(x) return x; end;


###UTIL FUNCTIONS FOR THE MAIN CONSTRUCTOR

#Getting the names for the families, returns the names in a list,
#for semigroups we expect them to have names
GetNames4CascadeProductComponents := function(components)
local names,comp;
  names := [];
  #the name of the family from the component names
  #if VERBOSE then Print("Getting component names");fi;
  for comp in components do
    if IsGroup(comp) then
      if SgpDecOptionsRec.SMALL_GROUPS then
        Add(names,StructureDescription(comp));
      else
        Add(names,Concatenation("G",StringPrint(Order(comp))));
      fi;
    else
      #if it has a name attached, then use it
      if HasName(comp) then
        Add(names,Name(comp));
      else
        Add(names,Concatenation("Sg",StringPrint(Size(comp))));
      fi;
    fi;
    #if VERBOSE then Print(".");fi;
  od;
  #if VERBOSE then Print("DONE\n");fi;
  return names;
end;

# SIMPLIFIED CONSTRUCTOR
# calling the main with default identity functions
InstallOtherMethod(CascadedStructure,[IsList],
function(components)
local statesym, opsym, comp,gid;

  statesym := [];
  opsym := [];
  for comp in components do
     Add(statesym, SGPDEC_idfunct);
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
local cascprodinfo,compnames,prodname,i,str,result,state_set_sizes;

  #GENERATING THE NAME
  #getting component names
  compnames := GetNames4CascadeProductComponents(components);

  #deciding whether it is a group or not and set the name accordingly
  if  ForAll(components, IsGroup) then
    prodname := "GroupCascade";
  else
    prodname := "MonoidCascade";
  fi;

  #concatenating component names
  for i in compnames do prodname := Concatenation(prodname,"_",i); od;

  #BUILDING THE INFO RECORD
  #this is the main record containing information about the cascade product,
  #the initial values do not matter
  cascprodinfo := rec(
  name_of_product := prodname,
  state_symbol_functions := statesymbolfunctions,
  operation_symbol_functions := operationsymbolfunctions,
  components := components,
  names_of_components := compnames,
  name_of_product := prodname
  );


  #guessing the statesets of the original components
  #if VERBOSE then Print("Guessing state sets");fi;
  cascprodinfo.state_sets := [];
  for i in components do
    if IsGroup(i) then
      Add(cascprodinfo.state_sets,MovedPoints(i));
    else
      Add(cascprodinfo.state_sets,
          [1..DegreeOfTransformation(Representative(i))]);
    fi;
    #if VERBOSE then Print(".\c");fi;
  od;
  #if VERBOSE then Print("DONE\n");fi;

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

  #CREATING TYPE INFO
  #creating family for operations
  if ForAll(components, IsGroup) then
    cascprodinfo.operation_family :=
      NewFamily(Concatenation(prodname,"_OperationsFamily"),
              IsCascadedPermutation);
    cascprodinfo.operation_type :=
      NewType(cascprodinfo.operation_family,
              IsCascadedPermutation);
  else
    cascprodinfo.operation_family :=
      NewFamily(Concatenation(prodname,"_OperationsFamily"),
              IsCascadedTransformation);
    cascprodinfo.operation_type :=
      NewType(cascprodinfo.operation_family,
              IsCascadedTransformation);
  fi;

  #creating type info for states
  cascprodinfo.state_family :=
    NewFamily(Concatenation(prodname,"_StatesFamily"),
            IsCascadedState);
  cascprodinfo.state_representation :=
    NewRepresentation(Concatenation(prodname,"_StateRepresentation"),
            IsComponentObjectRep,["coords"]);
  cascprodinfo.state_type :=
    NewType(cascprodinfo.state_family,
            IsCascadedState and cascprodinfo.state_representation );

  #creating type info for abstract states
  cascprodinfo.abstract_state_family :=
    NewFamily(Concatenation(prodname,"_StatesFamily"),
            IsAbstractCascadedState);
  cascprodinfo.abstract_state_representation :=
    NewRepresentation(Concatenation(prodname,"_StateRepresentation"),
            IsComponentObjectRep,["coords"]);
  cascprodinfo.abstract_state_type :=
    NewType(cascprodinfo.abstract_state_family,
            IsAbstractCascadedState and
            cascprodinfo.abstract_state_representation);

  #creating cascade state typed states
  #GENERATING STATES
  #if VERBOSE then Print("Generating states...");fi;
<<<<<<< local
  cascprodinfo.states := LazyCartesian(cascprodinfo.state_sets);
=======
  cascprodinfo.states := EnumeratorOfCartesianProduct(cascprodinfo.state_sets);            
>>>>>>> other
  #if VERBOSE then Print("DONE\n");fi;

  result :=  Objectify(CascadedStructureType,cascprodinfo);

  #linking from the family object to the product info,
  #thus we can get from any state/operation to this info struct
  result!.operation_family!.cstr := result;
  result!.state_family!.cstr := result;
  result!.abstract_state_family!.cstr := result;

  #making it immutable TODO this may not work
  cascprodinfo := Immutable(cascprodinfo);

  return result;
end);

#constructing monomial generators
InstallGlobalFunction(MonomialGenerators,
function(cstr)
local mongens, depth, compgen, gens, prefixes,prefix, newprefix, newprefixes, orbitreprs, orbits, orbit, orbrep, isgroup;
  #if not GroupsOnly(cstr) then Error("MonomialGenerators: currently only groups are supported.");fi;
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
        Add(mongens, DefineCascadedOperation(cstr,[[prefix,compgen]]));
      od;
    od;

    #getting the orbit reprs
    orbitreprs := [];
    if isgroup then
        orbits := Orbits(cstr[depth]);
    else
        orbits := SGPDEC_SingletonOrbits(cstr[depth]);
    fi;
    for orbit in orbits do
        if isgroup then 
            Add(orbitreprs, orbit[1]);
        else
            Append(orbitreprs, orbit); #this needs further tuning TODO if the semigroup is a group then the representative is enough
        fi;
    od;
    
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
end
);
 
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
end
);


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
    Print(i," ", s, Size(StateSets(castr)[i])," ");ViewObj(castr[i]);Print("\n"); #instead of printing the generators
    s := Concatenation(s,"|-");
  od;  
end
);


