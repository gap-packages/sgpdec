#############################################################################
##
## cascadeshell.gi           SgpDec package
##
## Copyright (C) 2008-2012
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##

#

InstallMethod(IsomorphismTransformationSemigroup, "for a cascade product",
[IsCascadeSemigroup],
function(s)
  local t, inv;
  t:=Semigroup(List(GeneratorsOfSemigroup(s), AsTransformation));
  inv:=function(f)
    local prefix, dom, n, func, visited, one, i, x, m, pos, j;
    prefix:=PrefixDomainOfCascadeSemigroup(s);
    dom:=DomainOfCascadeSemigroup(s);
    n:=NrComponentsOfCascadeSemigroup(s);
    func:=List(prefix, x-> List([1..Length(x)], x-> []));
    one:=List(prefix, x-> BlistList([1..Length(x)], [1..Length(x)]));
    
    for i in [1..DegreeOfTransformation(f)] do 
      x:=ShallowCopy(dom[i]);
      m:=n;
      Remove(x, m);
      pos:=Position(prefix[m], x);
      repeat
        func[m][pos][dom[i][m]]:=dom[i^f][m];
        if dom[i][m]<>func[m][pos][dom[i][m]] then 
          one[m][pos]:=false;
        fi;
        m:=m-1;
        if m=0 then 
          break;
        fi;
        Remove(x, m);
        pos:=Position(prefix[m], x);
      until IsBound(func[m][pos][dom[i][m]]);
    od;
    
    #post process
    for i in [1..Length(func)] do 
      for j in [1..Length(func[i])] do 
        if one[i][j] then 
          Unbind(func[i][j]);
        #elif IsPermGroup(ComponentsOfCascadeSemigroup(s)[i]) then 
        #  func[i][j]:=PermList(func[i][j]);
        else
          func[i][j]:=TransformationNC(func[i][j]);
        fi;
      od;
    od;

    return CreateCascade(dom,
     ComponentDomainsOfCascadeSemigroup(s), prefix, func);
  end;

  return MagmaIsomorphismByFunctionsNC(s, t, AsTransformation, inv);
end);

#

if GAPInfo.Version="4.dev" then 
  InstallMethod(ComponentsOfCascadeSemigroup, "for a cascade product",
  [IsCascadeSemigroup],
  function(s)
    local func, n, out, i, j, x;
    
    func:=List(GeneratorsOfSemigroup(s), x-> DependencyFunction(x)!.func);
    n:=NrComponentsOfCascadeSemigroup(s);
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
  InstallMethod(ComponentsOfCascadeSemigroup, "for a cascade product",
  [IsCascadeSemigroup],
  function(s)
    local func, n, out, i, j, x;
    
    func:=List(GeneratorsOfSemigroup(s), x-> DependencyFunction(x)!.func);
    n:=NrComponentsOfCascadeSemigroup(s);
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

InstallMethod(DomainOfCascadeSemigroup,
[IsCascadeSemigroup],
x-> DomainOfCascade(Representative(x)));

#

InstallMethod(IsListOfPermGroupsAndTransformationSemigroups,
[IsListOrCollection],
function(l)
  return not IsEmpty(l) and
         IsDenseList(l) and
         ForAll(l, x-> IsTransformationSemigroup(x) or IsPermGroup(x));
end);

#

InstallMethod(PrefixDomainOfCascadeSemigroup,
[IsCascadeSemigroup],
function(cascprod)
  return PrefixDomainOfCascade(Representative(cascprod));
end);

#

InstallOtherMethod(NrComponentsOfCascadeSemigroup,
[IsCascadeSemigroup],
function(cascprod)
  return Size(ComponentDomainsOfCascade(
                 Representative(cascprod)));
end);

#

InstallOtherMethod(ComponentDomainsOfCascadeSemigroup,
[IsListOrCollection],
function(comps)
  local domains, comp;
  if not IsListOfPermGroupsAndTransformationSemigroups(comps) then
    Error("insert meaningful error message here,");
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
[IsCascadeSemigroup and HasGeneratorsOfSemigroup],
function(s)
  local str, x;

  str:="<cascade semigroup with ";
  Append(str, String(Length(GeneratorsOfSemigroup(s))));
  Append(str, " generator");
  if Length(GeneratorsOfSemigroup(s))>1 then 
    Append(str, "s");
  fi;
  Append(str, ", ");
  Append(str, String(NrComponentsOfCascadeSemigroup(s)));
  Append(str, " levels");

  if Length(str)<SizeScreen()[1]-(NrComponentsOfCascadeSemigroup(s)*3)-12 then
    Append(str, " with (");
    for x in ComponentDomainsOfCascadeSemigroup(s) do
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

# the full cascade semigroup

InstallGlobalFunction(FullCascadeSemigroup, 
function(arg)
  local filts, s, i;

  if Length(arg)=1 then 
    if IsListOfPermGroupsAndTransformationSemigroups(arg[1]) then 
      arg:=arg[1];
    else
      Error("the argument must be a list of transformation semigroup and perm",
      " groups");
    fi;
  else 
    if not IsListOfPermGroupsAndTransformationSemigroups(arg) then 
      Error("the argument must consist of transformation semigroups and perm ",
      "groups,");
    fi;
  fi;

  for i in [1..Length(arg)] do 
    if IsPermGroup(arg[i]) then 
      arg[i]:=Semigroup(List(GeneratorsOfGroup(arg[i]), AsTransformation));
    fi;
  od;

  filts:=IsSemigroup and IsAttributeStoringRep and IsFullCascadeSemigroup ;
  s:=Objectify( NewType( CollectionsFamily(CascadeFamily), filts ), rec()); 
  SetComponentsOfCascadeSemigroup(s, arg);
  SetComponentDomainsOfCascadeSemigroup(s, List(arg, 
   x-> [1..DegreeOfTransformationSemigroup(x)]));
  return s; 
end);

#

InstallMethod(ViewObj, "for a full cascade semigroup",
[IsFullCascadeSemigroup],
function(s) 
  Print("<wreath product of semigroups>");
end);

#

InstallMethod(Size, "for a full cascade semigroup",
[IsFullCascadeSemigroup],
function(s)
  local domains, comps, order, j, i;

  domains:=List(ComponentDomainsOfCascadeSemigroup(s), Length);
  comps:=ComponentsOfCascadeSemigroup(s);
  order := 1;
  j := 1;
  for i in [1..Length(domains)] do
    order := order * (Size(comps[i])^j);
    j := j * domains[i];
  od;
  return order;
end);

# old

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

InstallOtherMethod(ComponentDomainsOfCascadeSemigroup,
        [IsCascadeSemigroup],
function(cascprod)
  return ComponentDomainsOfCascade(Representative(cascprod));
end);
