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
InstallMethod(IsomorphismPermGroup, "for a cascade group",
[IsCascadeGroup],
function(G)
  local H;
  H:=Group(List(GeneratorsOfGroup(G), AsPermutation));
  return MagmaIsomorphismByFunctionsNC(
                 G,
                 H,
                 AsPermutation,
                 f -> AsCascade(f, ComponentDomains(G)));
end);

InstallMethod(ComponentsOfCascadeGroup, "for a cascade product",
[IsCascadeGroup],
function(s)
  local func, n, out, i, j, x;

  func:=List(GeneratorsOfGroup(s), x-> DependencyFunction(x)!.func);
  n:=NrComponentsOfCascadeGroup(s);
  out:=List([1..n], x->[]);
  for i in [1..Length(GeneratorsOfGroup(s))] do
    for j in [1..n] do
      if not IsEmpty(func[i][j]) then
        if out[j]=[] then
          out[j]:=Group(Compacted(func[i][j]), rec(small:=true));
        else
          out[j]:=ClosureGroup(out[i], Compacted(func[i][j]));
        fi;
      fi;
    od;
  od;
  return out;
end);

################################################################################
# FULL CASCADE GROUP #######################################################
################################################################################
# the full cascade group
InstallGlobalFunction(FullCascadeGroup,
function(arg)
  local filts, s, i,n;

  if Length(arg)=1 then
    if ForAll(arg[1],IsPermGroup) then
      arg:=arg[1];
    else
      Error("the argument must be a list of perm groups");
    fi;
  else
    if not ForAll(arg,IsPermGroup) then
      Error("the argument must consist of perm groups,");
    fi;
  fi;
  filts:=IsGroup and IsAttributeStoringRep and IsFullCascadeGroup;
  s:=Objectify( NewType( CollectionsFamily(PermCascadeFamily), filts ), rec());
  SetComponentsOfCascadeGroup(s, arg);
  SetComponentDomains(s, ComponentDomains(arg));
  SetNrComponentsOfCascadeGroup(s, Length(arg));
  SetDependencyDomainsOf(s,
          DependencyDomains(ComponentDomains(s)));
  SetDomainOf(s,
          EnumeratorOfCartesianProduct(ComponentDomains(s)));
  return s;
end);

#former monomial generators
InstallMethod(GeneratorsOfGroup, "for a full cascade group",
[IsFullCascadeGroup],
function(s)
  local nr, comps, pts, prefix, dom, compdom, depdoms, gens, nrgens,
        m, pos, func, pre, x, y, i, depfuncs;

  nr:=NrComponentsOfCascadeGroup(s);
  comps:=ComponentsOfCascadeGroup(s);
  pts := List([1..nr], #TODO only one line and type is changed
              i-> List(Orbits(comps[i]),
                      o -> o[1]));
  #pts:=List([1..nr], i-> ActionRepresentatives(comps[i]));
  prefix:=DependencyDomains(pts);

  dom:=DomainOf(s);
  compdom:=ComponentDomains(s);
  depdoms:=DependencyDomainsOf(s);
  gens:=[]; nrgens:=0;

  for pre in prefix do
    for x in pre do
      m:=Length(x);
      pos:=Position(prefix[m+1], x);
      for y in GeneratorsOfGroup(comps[m+1]) do
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
                              PermCascadeType);
      od;
    od;
  od;

  return gens;
end);

################################################################################
# SIZE #########################################################################
################################################################################
InstallMethod(Size, "for a full cascade group",
[IsFullCascadeGroup],
function(s)
  return SizeOfIteratedTransformationWreathProduct(
                 List(ComponentDomains(s), Length),         #degrees
                 List(ComponentsOfCascadeGroup(s),Size) #orders
                 );
end);


################################################################################
# ADMINISTRATIVE METHODS #######################################################
################################################################################
InstallMethod(DomainOf,[IsCascadeGroup],
x-> DomainOf(Representative(x)));

InstallMethod(IsListOfPermGroups,
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
        [IsCascadeGroup],
function(cascprod)
  return ComponentDomains(Representative(cascprod));
end);

################################################################################
# PRINTING #####################################################################
################################################################################
InstallMethod(ViewObj, "for a full cascade group",
[IsFullCascadeGroup],
function(s)
  Print("<wreath product of perm groups>");
end);

InstallMethod(ViewObj, "for a cascade product",
[IsCascadeGroup and HasGeneratorsOfGroup],
function(s)
  local str, x;

  str:="<cascade group with ";
  Append(str, String(Length(GeneratorsOfGroup(s))));
  Append(str, " generator");
  if Length(GeneratorsOfGroup(s))>1 then
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
