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
  if Length(coords) = Length(cstr) then
    return Objectify(CascadedStateType,rec(coords:=coords,cstr:=cstr));
  else
    return Objectify(AbstractCascadedStateType,rec(coords:=coords,cstr:=cstr));
  fi;
end);

####LOWLEVEL YEAST#####################################
# Collapsing for states - just returning the index as the states are stored in
# order.
InstallOtherMethod(Flatten, "for a cascaded state",
[IsCascadedState],
function( cs )
  return PositionCanonical(States(CascadedStructureOf(cs)),cs);
end);

InstallOtherMethod(Flatten, "for an abstract cascaded state",
[IsAbstractCascadedState],
function( acs )
local l;     
  l := [];
  Perform(AllConcreteCascadedStates(acs), function(x) AddSet(l,Flatten(x));end);
  return  l;
end);


# Building cascaded states - since the states are stored in a list, the flat
# state is just the index
InstallOtherMethod(Raise, "for cascaded structure and integer",
[IsCascadedStructure, IsPosInt],
function( cstr, state ) return States(cstr)[state]; end);

#for abstract positions we put 1 (a surely valid coordinate value) replacing 0
InstallGlobalFunction(Concretize,
function(abstract_state)
local l, cstr;
  cstr := CascadedStructureOf(abstract_state);
  l := List(abstract_state, function(x) if x>0 then return x; else return 1;fi;end);
  #then append the list with 1s
  Append(l, ListWithIdenticalEntries(Length(cstr) - Size(abstract_state), 1));
  return CascadedState(cstr, l);
end);

InstallGlobalFunction(AllConcreteCascadedStates,
function(abstract_state)
local cstr, concretestates;
  cstr := CascadedStructureOf(abstract_state);    
  concretestates :=  EnumeratorOfCartesianProduct(
                             List([1..Size(cstr)],
    function(x) 
      if IsBound(abstract_state[x]) and abstract_state[x]>0 then 
        return [abstract_state[x]]; 
      else
        return StateSets(cstr)[x];
      fi;
    end));
  return List(concretestates, x -> CascadedState(cstr,x));
end);

###############################################################
############ OLD METHODS ######################################
###############################################################

# equality - just check the equality of the underlying lists, thus it works for
# abstract states as well
InstallOtherMethod(\=, "deciding equality of cascaded states", IsIdenticalObj,
[IsAbstractCascadedState, IsAbstractCascadedState],
function(p,q) return p!.coords = q!.coords; end);

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
    if i < Length(cstr) then
      Print(",");
    fi;
  od;
  Print(")");
  return;
end);

# for accessing the list elements
InstallOtherMethod( \[\], "for an abstract cascaded state and pos int",
[ IsAbstractCascadedState, IsPosInt ],
function( cs, pos ) return cs!.coords[pos]; end);

#################################################################
InstallMethod(Length,"for an abstract cascaded state",
[IsAbstractCascadedState],
function(cs) return Length(cs!.coords); end);

#################ACCESS FUNCTIONS######################
InstallMethod(CascadedStructureOf, "for an abstract cascaded state",
[IsAbstractCascadedState],
function(cs) return cs!.cstr; end);