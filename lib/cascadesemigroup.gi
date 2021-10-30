#############################################################################
##
## cascadesemigroup.gi           SgpDec package
##
## Copyright (C) 2008-2019
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

#this may produce something bigger than the actual component
InstallMethod(ComponentsOfCascadeProduct, "for a semigroup cascade product",
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
      if not IsEmpty(vals[i][j]) then #TODO removing the extra if
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
  local filts, s, i,n, comps, dom ,depdoms, compdoms;
  if Length(arg)=1 then #if one argument only, then it must be a list of comps
      arg:=arg[1];
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
  comps := arg;
  compdoms := CreateComponentDomains(comps);
  depdoms := DependencyDomains(compdoms);
  dom := EnumeratorOfCartesianProduct(compdoms);
  s := Semigroup(MonomialGenerators(comps, compdoms, depdoms, dom));
  SetComponentsOfCascadeProduct(s, comps);
  SetComponentDomains(s, compdoms);
  SetNrComponents(s, Length(comps));
  SetDependencyDomainsOf(s, depdoms);
  SetDomainOf(s,dom);
  SetIsFullCascadeProduct(s,true);#TODO why is it needed? It should be implied.
  SetIsFullCascadeSemigroup(s,true);
  return s;
end);

#former monomial generators

InstallGlobalFunction(MonomialGenerators,
function(comps, compdoms, depdoms, dom)
  local nr, pts, prefix, gens, nrgens,
        m, pos, func, pre, x, y, i, depfuncs;

  nr:=Size(comps);
  pts:=List([1..nr], i-> [1..DegreeOfTransformationSemigroup(comps[i])]);
  #quick hack removing now dubious ActionRepresentatives(comps[i]));
  prefix:=DependencyDomains(pts);


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
            if not IsOne(y) then func[i][pos]:=y; fi; #to avoid registing identities
          fi;
        od;
        nrgens:=nrgens+1;
        depfuncs := List([1..Length(func)],
                   x -> DependencyFunction(depdoms[x],func[x]));
        gens[nrgens]:=CreateCascade(
                              dom,
                              compdoms,
                              depfuncs,
                              depdoms,
                              TransCascadeType);
      od;
    od;
  od;

  return DuplicateFreeList(gens);
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
  Append(str, String(Length(Generators(s))));
  Append(str, " generator");
  if Length(Generators(s))>1 then
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

InstallOtherMethod(NrComponents,
[IsCascadeSemigroup],
function(cascprod)
  return Size(ComponentDomains(Representative(cascprod)));
end);


InstallOtherMethod(ComponentDomains,
        [IsCascadeSemigroup],
function(cascprod)
  return ComponentDomains(Representative(cascprod));
end);
