#############################################################################
##
## cascadedstate.gi           SgpDec package
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## 2008-2012
##
## Dealing with cascaded states.
##


# CONSTRUCTOR
# The actual cascaded states are reused. So the constructor just checks whether
# it is a valid list of coordinate values.

InstallGlobalFunction(CascadedState,
function(cstr,coords)
local i;
  #if the length is bigger then we fail (overspecialized!)
  if Length(coords) > Length(cstr)  then
    Print("Overspecialized! Too many levels!\n");
    return fail;
  fi;

  # checking whether the values are in range #TODO!! possibly a noncheck version
  # for speedup

  for i in [1..Length(coords)] do
    if coords[i] > Length(cstr!.state_sets[i]) or coords[i]<0 then
      Print(i,"th coordinate value out of range!\n");
      return fail;
    fi;
  od;

  # just a normal state not an abstract one  #TODO this one misses the zero
  # entries
  if Length(coords) =  Length(cstr) then
    return Objectify(CascadedStateType,rec(coords:=coords,cstr:=cstr));
  else
    return Objectify(AbstractCascadedStateType,rec(coords:=coords,cstr:=cstr));
  fi;
end);


####LOWLEVEL YEAST#####################################
# Collapsing for states - just returning the index as the states are stored in
# order.

InstallMethod(Collapse, "for a cascaded state",
[IsCascadedState],
function( cs )
  local cstr;

  cstr := CascadedStructureOf(cs);
  return PositionCanonical(States(cstr),cs);
end);


# Building cascaded states - since the states are stored in a list, the flat
# state is just the index

# JDM IsInt should be changd to IsPosInt, since States(cstr)[0],[-1]
# can never be returned.

InstallOtherMethod(Build, "for cascaded structure and integer",
[IsCascadedStructure, IsInt],
function( cstr, state )
  return States(cstr)[state];
end);

#it works only with prefixes
InstallGlobalFunction(Concretize,
function(abstract_state)
local l, cstr;
  cstr := CascadedStructureOf(abstract_state);
  l := ShallowCopy(AsList(abstract_state));
  #just putting 1s as a safe bet JDM ???
  Append(l, List([Size(abstract_state)+1..Length(cstr)], x -> 1));
  return CascadedState(cstr, l);
end);

###############################################################
############ OLD METHODS ######################################
###############################################################

# equality - just check the equality of the underlying lists, thus it works for
# abstract states as well

InstallOtherMethod(\=, "deciding equality of cascaded states", IsIdenticalObj,
[IsAbstractCascadedState, IsAbstractCascadedState],
function(p,q)
  return p!.coords = q!.coords;
end);

#############################################################################

InstallMethod( ViewObj, "for an abstract cascaded state",
[IsAbstractCascadedState],
function( cs )
  local i, cstr;

  cstr := CascadedStructureOf(cs);
  Print("C(");
  for i in [1..Length(cstr)] do
    if i <= Length(cs) and cs[i] > 0 then
      Print(cstr!.state_symbol_functions[i](cs[i]));
    else
      Print("*");
    fi;
    if i < Length(cs) then
      Print(",");
    fi;
  od;
  Print(")");
  return;
end);

# for accessing the list elements
InstallOtherMethod( \[\], "for an abstract cascaded state and pos int",
[ IsAbstractCascadedState, IsPosInt ],
function( cs, pos )
  return cs!.coords[pos];
end);

#################################################################

InstallMethod(Length,"for an abstract cascaded state",
[IsAbstractCascadedState],
function(cs)
  return Length(cs!.coords);
end);

#################ACCESS FUNCTIONS######################

InstallMethod(CascadedStructureOf, "for an abstract cascaded state",
[IsAbstractCascadedState],
function(cs)
  return cs!.cstr;
end);