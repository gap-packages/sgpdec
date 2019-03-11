#############################################################################
##
## coords.gi           SgpDec package
##
## Copyright (C) 2008-2015
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
function(compdoms, abstract_state)
local l;
  #first filling up with 0 if there are not enough coordinates
  l := ShallowCopy(abstract_state);
  Append(l,ListWithIdenticalEntries(Length(compdoms) - Size(abstract_state),0));
  #then replacing all zeroes with a valid coordinate
  l := List([1..Length(l)],
          function(i)
            if l[i]>0 then
              return l[i];
            else
              return Representative(compdoms[i]);
            fi;end);
  return l;
end);

InstallGlobalFunction(AllConcreteCoords,
function(compdoms, abstract_state)
  #the trick is to return an enumerator of domains for 0, singletons for a value
  return EnumeratorOfCartesianProduct(
                 List([1..Size(abstract_state)],
    function(x)
      if IsBound(abstract_state[x]) and abstract_state[x]>0 then #TODO Do we still have the zero convention?
        return [abstract_state[x]];
      else
        return compdoms[x];
      fi;
    end));
end);

################################################################################
# POINT-COORDINATES HOMOMORPHISM ###############################################

# maps (abstract) coordinates to points
InstallMethod(AsPoint, "for coordinates, componentdomains and domain",
[IsList, IsList, IsList],
function(coords, compdoms, dom)
  local l;
  if (Length(coords) = Size(compdoms)) and (Minimum(coords) > 0) then
    #if not abstract just return a point
    return PositionCanonical(dom,coords);
  else
    #if abstract return all points fitting the pattern
    l := [];
    Perform(AllConcreteCoords(compdoms,coords),
            function(x) AddSet(l,PositionCanonical(dom,x));end);
    return  l;
  fi;
end);

# maps (abstract) coordinates to points, required info from a cascade sgp
InstallOtherMethod(AsPoint, "for coordinates in a cascade product",
[IsList,IsCascadeSemigroup],
function(coords,cascsgp)
  return AsPoint(coords, ComponentDomains(cascsgp), DomainOf(cascsgp));
end);

# maps points to coordinates
InstallMethod(AsCoords, "for a point and domain",
[IsPosInt,IsList],
function(state,dom)
  return dom[state];
end);

# maps points to coordinates, required info from a cascade sgp
InstallOtherMethod(AsCoords, "for a point and cascade semigroup",
[IsPosInt,IsCascadeSemigroup],
function(state,cascsgp)
  return DomainOf(cascsgp)[state];
end);
