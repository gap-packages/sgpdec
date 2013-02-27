#############################################################################
##
## cascadeprod.gi           SgpDec package
##
## Copyright (C) 2008-2013
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##

#

InstallMethod(IsomorphismTransformationSemigroup, "for a cascade product",
[IsCascadeSemigroup],
function(s)
  local t;
  t:=Semigroup(List(GeneratorsOfSemigroup(s), AsTransformation));
  return MagmaIsomorphismByFunctionsNC(
                 s,
                 t,
                 AsTransformation,
                 f -> AsCascade(f, ComponentDomainsOfCascadeSemigroup(s)));
end);

#

#with ClosureSemigroup it is easier
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
  #ClosureSemigroup is not available
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
  return Size(ComponentDomains(Representative(cascprod)));
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

  for i in [1..Length(arg)] do
    if IsPermGroup(arg[i]) then
      #we need to know domain when converting to transformation
      n := LargestMovedPoint(arg[i]);
      arg[i]:=Semigroup(List(GeneratorsOfGroup(arg[i]),
                      g -> AsTransformation(g,n)));
    fi;
  od;

  filts:=IsSemigroup and IsAttributeStoringRep and IsFullCascadeSemigroup ;
  s:=Objectify( NewType( CollectionsFamily(CascadeFamily), filts ), rec());
  SetComponentsOfCascadeSemigroup(s, arg);
  SetComponentDomainsOfCascadeSemigroup(s, List(arg,
   x-> [1..DegreeOfTransformationSemigroup(x)]));
  SetNrComponentsOfCascadeSemigroup(s, Length(arg));
  SetPrefixDomainOfCascadeSemigroup(s,
   CreatePrefixDomains(ComponentDomainsOfCascadeSemigroup(s)));
  SetDomainOfCascadeSemigroup(s,
   EnumeratorOfCartesianProduct(ComponentDomainsOfCascadeSemigroup(s)));
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

#

InstallMethod(GeneratorsOfSemigroup, "for a full cascade semigroup",
[IsFullCascadeSemigroup],
function(s)
  local nr, comps, pts, prefix, dom, compdom, oldfix, gens, nrgens,
        m, pos, func, pre, x, y, i;

  nr:=NrComponentsOfCascadeSemigroup(s);
  comps:=ComponentsOfCascadeSemigroup(s);
  pts:=List([1..nr], i-> ActionRepresentatives(comps[i]));
  prefix:=CreatePrefixDomains(pts);

  dom:=DomainOfCascadeSemigroup(s);
  compdom:=ComponentDomainsOfCascadeSemigroup(s);
  oldfix:=PrefixDomainOfCascadeSemigroup(s);
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
        gens[nrgens]:=CreateCascade(dom, compdom, oldfix, func);
      od;
    od;
  od;

  return gens;
end);

# old

#this is a huge number even in small cases
#InstallGlobalFunction(SizeOfWreathProduct,
#function(csh)
#local order,j,i;
  #calculating the order of the cascade state set
 # order := 1;
  #j is the number of possible arguments on a given depth, i.e.\ the exponent
 # j := 1;
 # for i in [1..Size(csh)] do
#    order := order * (Size(csh[i])^j);
#    j := j * Size(CoordValSets(csh)[i]);
 # od;
 # return order;
#end);

InstallOtherMethod(ComponentDomainsOfCascadeSemigroup,
        [IsCascadeSemigroup],
function(cascprod)
  return ComponentDomains(Representative(cascprod));
end);
