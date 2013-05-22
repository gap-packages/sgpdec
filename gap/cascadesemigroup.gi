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

#with ClosureSemigroup it is easier
if GAPInfo.Version="4.dev" then
  InstallMethod(ComponentsOfCascadeProduct, "for a cascade product",
  [IsCascadeSemigroup],
  function(s)
    local func, n, out, i, j, x;

    func:=List(GeneratorsOfSemigroup(s), x-> DependencyFunction(x)!.func);
    n:=NrComponents(s);
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
  InstallMethod(ComponentsOfCascadeProduct, "for a cascade product",
  [IsCascadeSemigroup],
  function(s)
    local func, n, out, i, j, x;

    func:=List(GeneratorsOfSemigroup(s), x-> DependencyFunction(x)!.func);
    n:=NrComponents(s);
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
  s:=Objectify( NewType( CollectionsFamily(CascadeFamily), filts ), rec());
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
                   x -> DependencyFunction(depdoms[x],func[x]));
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
