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
# POINT-COORDINATES HOMOMORPHISM ###############################################

# maps (abstract) coordinates to points
InstallMethod(AsPoint, "for coordinates in a cascade shell",
[IsDenseList,IsCascadeShell],
function(coords,csh)
local l;
  if (Length(coords) = Size(csh)) and (Minimum(coords) > 0) then
    #if not abstract just return a point
    return PositionCanonical(AllCoords(csh),coords);
  else
    #if abstract return all points fitting the pattern
    l := [];
    Perform(AllConcreteCoords(csh,coords),
            function(x) AddSet(l,PositionCanonical(AllCoords(csh),x));end);
    return  l;
  fi;
end);

# ENA this will go to AsCoords method added to gd
InstallOtherMethod(Raise, "for lifting a point into a cascade shell",
[IsDenseList,IsPosInt],
function(csh,state) return AllCoords(csh)[state]; end);

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
        return CoordValSets(csh)[x];
      fi;
    end));
  return concretestates;
end);