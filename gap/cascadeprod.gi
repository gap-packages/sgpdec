#############################################################################
##
## cascadeshell.gi           SgpDec package
##
## Copyright (C) 2008-2012
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##

if GAPInfo.Version="4.dev" then 
  InstallMethod(ComponentsOfCascadeProduct, "for a cascade product",
  [IsCascadeProduct],
  function(s)
    local func, n, out, i, j, x;
    
    func:=List(GeneratorsOfSemigroup(s), x-> DependencyFunction(x)!.func);
    n:=NrComponentsOfCascadeProduct(s);
    out:=List([1..n], x->[]);

    for i in [1..Length(GeneratorsOfSemigroup(s))] do 
      for j in [1..n] do
        if not IsEmpty(func[i][j]) then
          if out[j]=[] then 
            out[j]:=Semigroup(Compacted(func[i][j]), rec(small:=true));
          else
            out[j]:=ClosureSemigroup(out[i], Compacted(func[i][j]));
          fi;
        fi;
      od;
    od;

    return out; 
  end);
else
  InstallMethod(ComponentsOfCascadeProduct, "for a cascade product",
  [IsCascadeProduct],
  function(s)
    local func, n, out, i, j, x;
    
    func:=List(GeneratorsOfSemigroup(s), x-> DependencyFunction(x)!.func);
    n:=NrComponentsOfCascadeProduct(s);
    out:=List([1..n], x->[]);

    for i in [1..Length(GeneratorsOfSemigroup(s))] do 
      for j in [1..n] do
        Append(out[i], Compacted(func[i][j]));
      od;
    od;

    Apply(out, 
      function(x)
        if not x=[] then 
          return Semigroup(x); 
        else 
          return x; 
        fi; 
      end);
    return out; 
  end);
fi;

#

InstallMethod(DomainOfCascadeProduct,
[IsCascadeProduct],
x-> DomainOfCascadeTransformation(Representative(x)));

#

InstallMethod(IsListOfPermGroupsAndTransformationSemigroups,
[IsListOrCollection],
function(l)
  return not IsEmpty(l) and
         IsDenseList(l) and
         ForAll(l, x-> IsTransformationSemigroup(x) or IsPermGroup(x));
end);

#

InstallMethod(PrefixDomainOfCascadeProduct,
[IsCascadeProduct],
function(cascprod)
  return PrefixDomainOfCascadeTransformation(Representative(cascprod));
end);

#

InstallOtherMethod(NrComponentsOfCascadeProduct,
[IsCascadeProduct],
function(cascprod)
  return Size(ComponentDomainsOfCascadeTransformation(
                 Representative(cascprod)));
end);

#

InstallOtherMethod(ComponentDomainsOfCascadeProduct,
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

InstallMethod(ViewObj, "for a cascade product",
[IsCascadeProduct],
function(s)
  local str, x;

  str:="<cascade semigroup with ";
  Append(str, String(Length(GeneratorsOfSemigroup(s))));
  Append(str, " generator");
  if Length(GeneratorsOfSemigroup(s))>1 then 
    Append(str, "s");
  fi;
  Append(str, ", ");
  Append(str, String(NrComponentsOfCascadeProduct(s)));
  Append(str, " levels");

  if Length(str)<SizeScreen()[1]-(NrComponentsOfCascadeProduct(s)*3)-12 then
    Append(str, " with (");
    for x in ComponentDomainsOfCascadeProduct(s) do
      Append(str, String(Length(x)));
      Append(str, ", ");
    od;
    Remove(str, Length(str));
    Remove(str, Length(str));
    Append(str, ") pts");
  fi;
  Append(str, ">");
  Print(str);
  return;
end);

# old

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
  #calculating the order of the cascade state set
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

InstallOtherMethod(ComponentDomainsOfCascadeProduct,
        [IsCascadeProduct],
function(cascprod)
  return ComponentDomainsOfCascadeTransformation(Representative(cascprod));
end);
