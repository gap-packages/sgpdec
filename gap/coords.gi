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


####LOWLEVEL YEAST#####################################
# Collapsing for states - just returning the index as the states are stored in
# order.
# The actual cascaded states are reused. So the constructor just checks whether
# it is a valid list of coordinate values.
InstallOtherMethod(Flatten, "for coordinates",
[IsCascadeShell,IsDenseList],
function(csh, coords)
local l;
  if (Length(coords) = Size(csh)) and (Minimum(coords) > 0) then
    return PositionCanonical(AllCoords(csh),coords);
  else
    l := [];
    Perform(AllConcreteCoords(csh,coords),
            function(x) AddSet(l,PositionCanonical(AllCoords(csh),x));end);
    return  l;
  fi;
end);

# Building cascaded states - since the states are stored in a list, the flat
# state is just the index
InstallOtherMethod(Raise, "for cascade shell and integer (flat state)",
[IsDenseList, IsPosInt],
function( csh, state ) return AllCoords(csh)[state]; end);

#for abstract positions we put 1 (a surely valid coordinate value) replacing 0
InstallGlobalFunction(Concretize,
function(csh, abstract_state)
local l;
  l := List(abstract_state,
            function(x) if x>0 then return x; else return 1;fi;end);
  #then append the list with 1s
  Append(l, ListWithIdenticalEntries(Length(csh) - Size(abstract_state), 1));
  return l;
end);

InstallGlobalFunction(AllConcreteCoords,
function(csh, abstract_state)
local concretestates;
  concretestates := EnumeratorOfCartesianProduct(
                            List([1..Size(csh)],
    function(x)
      if IsBound(abstract_state[x]) and abstract_state[x]>0 then
        return [abstract_state[x]];
      else
        return StateSets(csh)[x];
      fi;
    end));
  return concretestates;
end);