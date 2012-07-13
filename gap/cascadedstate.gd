#############################################################################
##
## cascadedstate.gd           SgpDec package
##
## Copyright (C) 2008-2012
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Declarations for  cascaded states.
##

DeclareGlobalFunction("CascadedState");
# returns a representative concrete cascaded state corresponding
# to an abstract state
DeclareGlobalFunction("Concretize");
DeclareGlobalFunction("AllConcreteCascadedStates");

DeclareCategory("IsAbstractCascadedState",IsDenseList);
DeclareCategory("IsCascadedState",IsAbstractCascadedState);

#creating type info for states
CascadedStateFamily := NewFamily("CascadedStatesFamily",IsCascadedState);
IsCascadedStateRep := NewRepresentation(
                                       "IsCascadedStateRep",
                                       IsComponentObjectRep,["coords","cstr"]);
CascadedStateType := NewType(CascadedStateFamily,
                             IsCascadedState and IsCascadedStateRep);

#creating type info for abstract states
AbstractCascadedStateFamily := NewFamily("AbstractCascadedStateFamily",
                                       IsAbstractCascadedState);
IsAbstractCascadedStateRep :=
    NewRepresentation("IsAbstractCascadedStateRep",
    IsCascadedStateRep,[]);
AbstractCascadedStateType := NewType(AbstractCascadedStateFamily,
                             IsAbstractCascadedState and
                             IsAbstractCascadedStateRep);