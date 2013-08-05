#############################################################################
##
## coords.gi           SgpDec package
##
## Copyright (C) 2008-2012
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## List of integers as coordinates.
##

################################################################################
# ABSTRACT COORDINATES #########################################################

#making an abstract state into a concrete
#0 means, don't care, or any coordval
#for abstract positions we put a surely valid coordinate value replacing 0
InstallGlobalFunction(Concretize,
function(domains, abstract_state)
local l;
  #first filling up with 0 if there are not enough coordinates
  l := ShallowCopy(abstract_state);
  Append(l, ListWithIdenticalEntries(Length(domains) - Size(abstract_state),0));
  #then replacing all zeroes with a valid coordinate
  l := List([1..Length(l)],
          function(i)
            if l[i]>0 then
              return l[i];
            else
              return Representative(domains[i]);
            fi;end);
  return l;
end);

InstallGlobalFunction(AllConcreteCoords,
function(domains, abstract_state)
  #the trick is to return an enumerator domains for 0, singletons for a value
  return EnumeratorOfCartesianProduct(
                 List([1..Size(abstract_state)],
    function(x)
      if IsBound(abstract_state[x]) and abstract_state[x]>0 then
        return [abstract_state[x]];
      else
        return domains[x];
      fi;
    end));
end);

################################################################################
# POINT-COORDINATES HOMOMORPHISM ###############################################

# maps (abstract) coordinates to points
InstallMethod(AsPoint, "for coordinates in a cascade product",
[IsDenseList,IsCascadeSemigroup],
function(coords,cascprod)
  local l,domains,dom;
  domains := ComponentDomains(cascprod);
  dom := DomainOf(cascprod);
  if (Length(coords) = Size(domains)) and (Minimum(coords) > 0) then
    #if not abstract just return a point
    return PositionCanonical(dom,coords);
  else
    #if abstract return all points fitting the pattern
    l := [];
    Perform(AllConcreteCoords(domains,coords),
            function(x) AddSet(l,PositionCanonical(dom,x));end);
    return  l;
  fi;
end);

InstallOtherMethod(AsCoords, "for lifting a point into a cascade shell",
[IsPosInt,IsCascadeSemigroup],
function(state,cascprod)
  return DomainOf(cascprod)[state];
end);
