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
function(compdoms, abstract_state)
local l;
  #first filling up with 0
  l := ShallowCopy(abstract_state);
  Append(l,ListWithIdenticalEntries(Length(compdoms) - Size(abstract_state),0));
  l := List([1..Length(l)],
          function(i)
            if l[i]>0 then
              return l[i];
            else
              return Representative(compdoms[i]);
            fi;end);
  #then append the list with some elements
  return l;
end);

InstallGlobalFunction(AllConcreteCoords,
function(compdoms, abstract_state)
local concretestates;
  concretestates := EnumeratorOfCartesianProduct(
                            List([1..Size(abstract_state)],
    function(x)
      if IsBound(abstract_state[x]) and abstract_state[x]>0 then
        return [abstract_state[x]];
      else
        return compdoms[x];
      fi;
    end));
  return concretestates;
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

# maps (abstract) coordinates to points
InstallOtherMethod(AsPoint, "for coordinates in a cascade product",
[IsList,IsCascadeSemigroup],
function(coords,cascprod)
  return AsPoint(coords, ComponentDomains(cascprod), DomainOf(cascprod));
end);

InstallMethod(AsCoords, "for a point and domain",
[IsPosInt,IsList],
function(state,dom)
  return dom[state];
end);

InstallOtherMethod(AsCoords, "for lifting a point into a cascade shell",
[IsPosInt,IsCascadeSemigroup],
function(state,cascprod)
  return DomainOf(cascprod)[state];
end);
