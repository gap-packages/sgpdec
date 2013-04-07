################################################################################
# ADMINISTRATIVE METHODS #######################################################
################################################################################
InstallMethod(DomainOf,[IsCascadeProduct],
x-> DomainOf(Representative(x)));

InstallMethod(IsListOfPermGroupsAndTransformationSemigroups,
[IsListOrCollection],
function(l)
  return not IsEmpty(l) and
         IsDenseList(l) and
         ForAll(l, x-> IsTransformationSemigroup(x) or IsPermGroup(x));
end);

InstallOtherMethod(NrComponents,
[IsCascadeProduct],
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
        [IsCascadeProduct],
function(cascprod)
  return ComponentDomains(Representative(cascprod));
end);
