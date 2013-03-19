InstallOtherMethod(OneOp, "for a permutation cascade",
[IsPermCascade],
function(ct)
  return IdentityCascade(ComponentDomains(ct));
end);


InstallOtherMethod(InverseMutable, "for a permutation cascade",
[IsPermCascade],
  function(pc)
  local dfs, depdoms, vals, x, i, j, depfuncs,type,pos;

  dfs:=DependencyFunctionsOf(pc);
  depdoms:=DependencyDomainsOf(pc); #TODO get rid of this
  #empty values lookup table based on the sizes of depdoms
  vals:=List(depdoms, x-> EmptyPlist(Length(x)));
  #going through all depdoms
  for i in [1..Length(depdoms)] do
    for j in [1..Length(depdoms[i])] do
      x:= OnDepArg(depdoms[i][j],dfs[i]);
      if not IsOne(x) then
        vals[i][Position(depdoms[i],OnCoordinates(depdoms[i][j],pc))]
          :=Inverse(x);
      fi;
    od;
  od;
  depfuncs := List([1..Length(vals)],
                   x -> CreateDependencyFunction(depdoms[x],vals[x]));
  return CreateCascade(DomainOf(pc),
                 ComponentDomains(pc),
                 depfuncs,
                 PermCascadeType);
end);
