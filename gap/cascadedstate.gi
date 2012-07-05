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

#CONSTRUCTOR
#The actual cascaded states are reused. Therefore the constructor just checks
#whether it is a valid list of coordinate values.
InstallGlobalFunction(CascadedState,
function(cstr,coords)
local i;
  #if the length is bigger then we fail (overspecialized!)
  if Length(coords) > Length(cstr)  then
    Print("Overspecialized! Too many levels!\n");
    return fail;
  fi;
  #checking whether the values are in range #TODO!! possibly a noncheck version
  for i in [1..Length(coords)] do
    if coords[i] > Length(cstr!.state_sets[i]) or coords[i]<0 then
      Print(i,"th coordinate value out of range!\n");
      return fail;
    fi;
  od;
  #just a normal state not an abstract one  #TODO this misses the zero entries
  if Length(coords) =  Length(cstr) then
      return Objectify(cstr!.state_type,rec(coords:=coords));
  #in the case of an  abstract state we need to check the coordinates
  else
      return Objectify(cstr!.abstract_state_type,rec(coords:=coords));
  fi;
end
);


####LOWLEVEL YEAST#####################################
# Collapsing for states - just returning the index of the cascaded state.
InstallMethod(Collapse,
    "maps a cascade state to a simple point",
    true,
    [IsCascadedState], 0,
function(cs)
local states,i,l,cstr,cslist;
  #we get the cascaded structure
  cstr := CascadedStructureOf(cs);
  #then just look for its index
  return PositionCanonical(States(cstr),cs);
end
);

#Building cascaded states - the flat state is just the index
InstallOtherMethod(Build,
    "gives the cascade state representation of state",
    true,
    [IsCascadedStructure,IsInt], 0,
function( cstr, state )
  return States(cstr)[state];
end
);

#it works only with prefixes
InstallGlobalFunction(Concretize,
function(abstract_state)
local l,cstr;
  cstr := CascadedStructureOf(abstract_state);  l := ShallowCopy(AsList(abstract_state));
  #just putting 1s as a safe bet
  Append(l, List([Size(abstract_state)+1..Length(cstr)], x -> 1));
  return CascadedState(cstr, l);
end
);

###############################################################
############ OLD METHODS ######################################
###############################################################


###########
#equality - just check the equality of the underlying lists,
#thus it works for abstract states as well
InstallOtherMethod(\=, "deciding equality of cascaded states", IsIdenticalObj,
        [IsAbstractCascadedState, IsAbstractCascadedState], 0,
function(p,q)
  return p!.coords = q!.coords;
end
);

#############################################################################
# Implementing Display, printing nice, human readable format.
InstallMethod( ViewObj,
    "displays a cascaded product state",
    true,
    [IsAbstractCascadedState], 0,
function( cs )
local i,cstr;

  #getting the cascaded structure
  cstr := CascadedStructureOf(cs);
  Print("C(");
  for i in [1..Length(cstr)] do
    if i <= Length(cs) and cs[i] > 0 then
      Print(cstr!.state_symbol_functions[i](cs[i]));
    else
      Print("*");
    fi;
    if i < Length(cs) then Print(",");fi;
  od;
  Print(")\n");
end
);

# for accessing the list elements
InstallOtherMethod( \[\],
    "for (abstract) cascaded states",
    [ IsAbstractCascadedState, IsPosInt ],
function( cs, pos )
  return cs!.coords[pos];
end
);

#################################################################
#Implementing Length
InstallMethod(Length,"for cascaded states",true,[IsAbstractCascadedState],
function(cs)
  return Length(cs!.coords);
end
);

#################ACCESS FUNCTIONS#######################
# returning parent cascaded structure
InstallMethod(CascadedStructureOf,
        "for cascaded states",
        true,
        [IsAbstractCascadedState],
function(cs)
  return FamilyObj(cs)!.cstr;
end
);