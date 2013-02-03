#############################################################################
##
## cascadeshell.gi           SgpDec package
##
## Copyright (C) 2008-2012
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## An empty shell defined by an ordered list of components.
## Used for defining cascaded structures.
##

InstallMethod(IsListOfPermGroupsAndTransformationSemigroups,
        [IsListOrCollection],
function(l)
  return not IsEmpty(l) and
         IsDenseList(l) and
         ForAll(l, x-> IsTransformationSemigroup(x) or IsPermGroup(x));
end);

InstallOtherMethod(DomainsOfCascadeProductComponents,
        [IsListOrCollection],
function(comps)
  local domains, comp;
  if not IsListOfPermGroupsAndTransformationSemigroups(comps) then
    Error("not components");
    return;
  fi;
  domains:=[];
  for comp in comps do
    if IsTransformationSemigroup(comp) then
      Add(domains, [1..DegreeOfTransformationSemigroup(comp)]);
    else
      Add(domains, MovedPoints(comp));
    fi;
  od;
  return domains;
end);

#

InstallGlobalFunction(CascadeProduct, 
function(arg)

  #record.enum:=EnumeratorOfCartesianProduct(record.domains);
  # get the generators, create the object using the family of the generators,
  # and a new type (as in semigroups.gi) ...
  #out:=Objectify();

end);

###UTIL FUNCTIONS FOR THE MAIN CONSTRUCTOR

# Constructing a short name for a component
# 1. If it has a name just return it.
# 2. For a group when the Small Group's Library allowed, then use that
# 3. Otherwise S_order for semigroups, G_order for groups
# Side effect! This actually sets the name for the component if missing.
Name4Component := function(comp)
  if HasName(comp) then
    return Name(comp);
  fi;

  if IsGroup(comp) then
    if SgpDecOptionsRec.SMALL_GROUPS then
      SetName(comp, StructureDescription(comp));
    else
      SetName(comp, Concatenation("G",String(Order(comp))));
    fi;
  else
    SetName(comp, Concatenation("sg",String(Size(comp))));
  fi;
  return Name(comp);
end;
MakeReadOnlyGlobal("Name4Component");

# TODO this is for the number of dependency entries
#  state_set_sizes := List(cascprodinfo.coordval_sets, x-> Size(x));
#  cascprodinfo.num_of_dependency_entries :=
#    Sum(List([1..Size(components)], x-> Product(state_set_sizes{[1..x-1]})));


#######################ACCESS METHODS#######################
InstallGlobalFunction(AllCoords,
function(csh) return csh!.allcoords; end);

InstallGlobalFunction(CoordValSets,
function(csh) return csh!.coordval_sets; end);

InstallGlobalFunction(NumberOfDependencyFunctionArguments,
function(csh) return csh!.num_of_dependency_entries; end);

InstallGlobalFunction(NameOfDependencyDomain,
function(csh,level) return csh!.depdom_names[level]; end);

InstallGlobalFunction(CoordValConverter,
function(csh,level) return csh!.coordval_converters[level]; end);

InstallGlobalFunction(CoordTransConverter,
function(csh,level) return csh!.coordtrans_converters[level]; end);

InstallOtherMethod(Name,"for cascade shells",[IsList],
function(csh) return csh!.name_of_shell; end);

#this is a huge number even in small cases
InstallGlobalFunction(SizeOfWreathProduct,
function(csh)
local order,j,i;
  #calculating the order of the cascaded state set
  order := 1;
  #j is the number of possible arguments on a given depth, i.e.\ the exponent
  j := 1;
  for i in [1..Size(csh)] do
    order := order * (Size(csh[i])^j);
    j := j * Size(CoordValSets(csh)[i]);
  od;
  return order;
end);

#######################OLD METHODS#############################
# The size of the cascade shell is the number components.
InstallMethod(Length,"for cascade shells",true,[IsList],
function(csh)
  return Length(csh!.components);
end);

# for accessing the list elements
InstallOtherMethod( \[\],
    "for cascade shells",
    [ IsList, IsPosInt ],
function( csh, pos )
return csh!.components[pos];
end);

#############################################################################
# Implementing Display, printing nice, human readable format.
InstallMethod( ViewObj,
    "for a cascade shell",
    true,
    [IsList],
function(csh) Print(Name(csh));end);

InstallMethod(Display,
    "for a cascade shell",
    true,
    [IsList],
function(csh)
local s,i;
  s := "";
  for i in [1..Length(csh)] do
    Print(i," ", s,"(",Size(CoordValSets(csh)[i]),",");
    ViewObj(csh[i]);
    Print(")\n");
    s := Concatenation(s,"|-");
  od;
end);
