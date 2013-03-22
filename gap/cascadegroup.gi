#############################################################################
##
## cascadeprod.gi           SgpDec package
##
## Copyright (C) 2008-2013
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##

################################################################################
# CASCADE GROUP ################################################################
################################################################################
InstallMethod(IsomorphismPermGoup, "for a cascade group",
[IsCascadeGroup],
function(G)
  local H;
  H:=Group(List(GeneratorsOfGroup(G), AsPermutation));
  return MagmaIsomorphismByFunctionsNC(
                 G,
                 H,
                 AsPermutation,
                 f -> AsPermCascade(f, ComponentDomains(s)));
end);

#with ClosureSemigroup it is easier
if GAPInfo.Version="4.dev" then
  InstallMethod(ComponentsOfCascadeGroup, "for a cascade product",
  [IsCascadeGroup],
  function(s)
    local func, n, out, i, j, x;

    func:=List(GeneratorsOfSemigroup(s), x-> DependencyFunction(x)!.func);
    n:=NrComponentsOfCascadeGroup(s);
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
  #ClosureSemigroup is not available
  InstallMethod(ComponentsOfCascadeGroup, "for a cascade product",
  [IsCascadeGroup],
  function(s)
    local func, n, out, i, j, x;

    func:=List(GeneratorsOfSemigroup(s), x-> DependencyFunction(x)!.func);
    n:=NrComponentsOfCascadeGroup(s);
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

################################################################################
# FULL CASCADE SEMIGROUP #######################################################
################################################################################
InstallGlobalFunction(FullCascadeGroup,
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

  filts:=IsSemigroup and IsAttributeStoringRep and IsFullCascadeGroup ;
  s:=Objectify( NewType( CollectionsFamily(CascadeFamily), filts ), rec());
  SetComponentsOfCascadeGroup(s, arg);
  SetComponentDomains(s, ComponentDomains(arg));
  SetNrComponentsOfCascadeGroup(s, Length(arg));
  SetDependencyDomainsOf(s,
   DependencyDomains(ComponentDomains(s)));
  SetDomainOf(s,
   EnumeratorOfCartesianProduct(ComponentDomains(s)));
  return s;
end);

# the full cascade group
#InstallGlobalFunction(FullCascadeGroup,
#function(arg)
#  local filts, s, i,n;

#  if Length(arg)=1 then
#    if ForAll(arg[1],IsPermGroup) then
#      arg:=arg[1];
#    else
#      Error("the argument must be a list of perm groups");
#    fi;
#  else
#    if not ForAll(arg,IsPermGroup) then
#      Error("the argument must consist of perm groups,");
#    fi;
#  fi;

#  filts:=IsGroup and IsAttributeStoringRep and IsFullCascadeGroup;
#  s:=Objectify( NewType( CollectionsFamily(PermCascadeFamily), filts ), rec());
#  SetComponentsOfCascadeGroup(s, arg);
#  SetComponentDomains(s, ComponentDomains(arg));
#  SetNrComponentsOfCascadeGroup(s, Length(arg));
#  SetDependencyDomainsOf(s,
#          DependencyDomains(ComponentDomains(s)));
#  SetDomainOf(s,
#          EnumeratorOfCartesianProduct(ComponentDomains(s)));
#  return s;
#end);

#former monomial generators
InstallMethod(GeneratorsOfSemigroup, "for a full cascade semigroup",
[IsFullCascadeGroup],
function(s)
  local nr, comps, pts, prefix, dom, compdom, depdoms, gens, nrgens,
        m, pos, func, pre, x, y, i, depfuncs;

  nr:=NrComponentsOfCascadeGroup(s);
  comps:=ComponentsOfCascadeGroup(s);
  pts:=List([1..nr], i-> ActionRepresentatives(comps[i]));
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
                   x -> CreateDependencyFunction(depdoms[x],func[x]));
        gens[nrgens]:=CreateCascade(
                              DomainOf(s),
                              ComponentDomains(s),
                              depfuncs,
                              CascadeType);
      od;
    od;
  od;

  return gens;
end);

################################################################################
# SIZE #########################################################################
################################################################################
InstallMethod(Size, "for a full cascade semigroup",
[IsFullCascadeGroup],
function(s)
  return SizeOfIteratedTransformationWreathProduct(
                 List(ComponentDomains(s), Length),         #degrees
                 List(ComponentsOfCascadeGroup(s),Size) #orders
                 );
end);

#this is a huge number even in small cases
InstallGlobalFunction(SizeOfIteratedTransformationWreathProduct,
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
InstallMethod(DomainOf,[IsCascadeGroup],
x-> DomainOf(Representative(x)));

InstallMethod(IsListOfPermGroupsAndTransformationSemigroups,
[IsListOrCollection],
function(l)
  return not IsEmpty(l) and
         IsDenseList(l) and
         ForAll(l, IsPermGroup);
end);

InstallOtherMethod(NrComponentsOfCascadeGroup,
[IsCascadeGroup],
function(cascprod)
  return Size(ComponentDomains(Representative(cascprod)));
end);

InstallOtherMethod(ComponentDomains,
[IsListOrCollection],
function(comps)
  local domains, comp;
  if not IsListOfPerm(comps) then
    Error("insert meaningful error message here,");
    return;
  fi;
  domains:=[];
  for comp in comps do
    Add(domains, MovedPoints(comp));
  od;
  return domains;
end);


InstallOtherMethod(ComponentDomains,
        [IsCascadeGroup],
function(cascprod)
  return ComponentDomains(Representative(cascprod));
end);

################################################################################
# PRINTING #####################################################################
################################################################################
InstallMethod(ViewObj, "for a full cascade semigroup",
[IsFullCascadeGroup],
function(s)
  Print("<wreath product of semigroups>");
end);

InstallMethod(ViewObj, "for a cascade product",
[IsCascadeGroup and HasGeneratorsOfGroup],
function(s)
  local str, x;

  str:="<cascade group with ";
  Append(str, String(Length(GeneratorsOfSemigroup(s))));
  Append(str, " generator");
  if Length(GeneratorsOfSemigroup(s))>1 then
    Append(str, "s");
  fi;
  Append(str, ", ");
  Append(str, String(NrComponentsOfCascadeGroup(s)));
  Append(str, " levels");

  if Length(str)<SizeScreen()[1]-(NrComponentsOfCascadeGroup(s)*3)-12 then
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
