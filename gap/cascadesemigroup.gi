#############################################################################
##
## cascadesemigroup.gi           SgpDec package
##
## Copyright (C) 2008-2013
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##

################################################################################
# CASCADE SEMIGROUP ############################################################
################################################################################
InstallMethod(IsomorphismTransformationSemigroup, "for a cascade product",
[IsCascadeSemigroup],
function(s)
  local t;
  t:=Semigroup(List(GeneratorsOfSemigroup(s), AsTransformation));
  return MagmaIsomorphismByFunctionsNC(
                 s,
                 t,
                 AsTransformation,
                 f -> AsCascade(f, ComponentDomains(s)));
end);

InstallMethod(ComponentsOfCascadeProduct, "for a cascade product",
        [IsCascadeSemigroup],
function(s)
  local vals, n, comp, i, j;
  vals:=List(GeneratorsOfSemigroup(s),
             x-> List(DependencyFunctionsOf(x),
                     y->DependencyValues(y)));
  n:=NrComponents(s);
  comp:=List([1..n], x->[]);
  #ith generator
  for i in [1..Length(vals)] do
    #jth level
    for j in [1..n] do
      if not IsEmpty(vals[i][j]) then
        if comp[j]=[] then
          comp[j]:=Semigroup(vals[i][j]);
        else
          comp[j]:=ClosureSemigroup(comp[j], vals[i][j]);
        fi;
      fi;
    od;
  od;
  return comp;
end);

################################################################################
# FULL CASCADE SEMIGROUP #######################################################
################################################################################
InstallGlobalFunction(FullCascadeSemigroup,
function(arg)
  local filts, s, i,n;

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
  #converting group components to semigroups
  for i in [1..Length(arg)] do
    if IsPermGroup(arg[i]) then
      #we need to know domain when converting to transformation
      n := LargestMovedPoint(arg[i]);
      arg[i]:=Semigroup(List(GeneratorsOfGroup(arg[i]),
                      g -> AsTransformation(g,n)));
    fi;
  od;

  filts:=IsSemigroup and IsAttributeStoringRep and IsFullCascadeSemigroup ;
  s:=Objectify( NewType( CollectionsFamily(TransCascadeFamily), filts ), rec());
  SetComponentsOfCascadeProduct(s, arg);
  SetComponentDomains(s, ComponentDomains(arg));
  SetNrComponents(s, Length(arg));
  SetDependencyDomainsOf(s,
   DependencyDomains(ComponentDomains(s)));
  SetDomainOf(s,
   EnumeratorOfCartesianProduct(ComponentDomains(s)));
  SetIsFullCascadeProduct(s,true);#TODO why is it needed? It should be implied.
  return s;
end);

#former monomial generators
InstallMethod(GeneratorsOfSemigroup, "for a full cascade semigroup",
[IsFullCascadeSemigroup],
function(s)
  local nr, comps, pts, prefix, dom, compdom, depdoms, gens, nrgens,
        m, pos, func, pre, x, y, i, depfuncs;

  nr:=NrComponents(s);
  comps:=ComponentsOfCascadeProduct(s);
  pts:=List([1..nr], i-> [1..DegreeOfTransformationSemigroup(comps[i])]);
  #quick hack removing now dubious ActionRepresentatives(comps[i]));
  prefix:=DependencyDomains(pts);

  dom:=DomainOf(s);
  compdom:=ComponentDomains(s);
  depdoms:=DependencyDomainsOf(s);
  gens:=[]; nrgens:=0;

  for pre in prefix do
    for x in pre do
      m:=Length(x);
      pos:=Position(prefix[m+1], x);
      for y in GeneratorsOfSemigroup(comps[m+1]) do
        func:=EmptyPlist(nr);
        for i in [1..nr] do
          if i<>m+1 then
            func[i]:=EmptyPlist(0);
          else
            func[i]:=EmptyPlist(pos);
            func[i][pos]:=y;
          fi;
        od;
        nrgens:=nrgens+1;
        depfuncs := List([1..Length(func)],
                   x -> DependencyFunction(depdoms[x],func[x]));
        gens[nrgens]:=CreateCascade(
                              DomainOf(s),
                              ComponentDomains(s),
                              depfuncs,
                              depdoms,
                              TransCascadeType);
      od;
    od;
  od;

  return gens;
end);

################################################################################
# PRINTING #####################################################################
################################################################################
InstallMethod(ViewObj, "for a full cascade semigroup",
[IsFullCascadeSemigroup],
function(s)
  Print("<wreath product of semigroups>");
end);

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
  Append(str, String(NrComponents(s)));
  Append(str, " levels");

  if Length(str)<SizeScreen()[1]-(NrComponents(s)*3)-12 then
    Append(str, " with (");
    for x in ComponentDomains(s) do
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

InstallMethod(Size, "for a full cascade semigroup",
[IsFullCascadeProduct],
function(cascprod)
  return SizeOfFullCascadeProduct(
                 List(ComponentDomains(cascprod), Length),       #degrees
                 List(ComponentsOfCascadeProduct(cascprod),Size) #orders
                 );
end);

#this is a huge number even in small cases
InstallGlobalFunction(SizeOfFullCascadeProduct,
function(degrees, orders)
local order,j,i;
  #calculating the order of the cascade state set
  order := 1;
  #j is the number of possible arguments on a given depth, i.e.\ the exponent
  j := 1;
  for i in [1..Size(orders)] do
    order := order * (orders[i]^j);
    j := j * degrees[i];
  od;
  return order;
end);

################################################################################
# ADMINISTRATIVE METHODS #######################################################
################################################################################
InstallMethod(DomainOf,[IsCascadeSemigroup],
x-> DomainOf(Representative(x)));

InstallMethod(IsListOfPermGroupsAndTransformationSemigroups,
[IsListOrCollection],
function(l)
  return not IsEmpty(l) and
         IsDenseList(l) and
         ForAll(l, x-> IsTransformationSemigroup(x) or IsPermGroup(x));
end);

InstallOtherMethod(NrComponents,
[IsCascadeSemigroup],
function(cascprod)
  return Size(ComponentDomains(Representative(cascprod)));
end);

InstallOtherMethod(ComponentDomains,
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


InstallOtherMethod(ComponentDomains,
        [IsCascadeSemigroup],
function(cascprod)
  return ComponentDomains(Representative(cascprod));
end);
