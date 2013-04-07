################################################################################
# SIZE #########################################################################
################################################################################
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
