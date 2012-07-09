#############################################################################
##
## cascadedstate.gd           SgpDec package
##
## Copyright (C) Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## 2008-2012
##
## Declarations for  cascaded states.
##

DeclareGlobalFunction("CascadedState");
# returns a representative concrete cascaded state corresponding
# to an abstract state
DeclareGlobalFunction("Concretize");

DeclareCategory("IsAbstractCascadedState",IsDenseList);
DeclareCategory("IsCascadedState",IsAbstractCascadedState);

#creating type info for states
CascadedStateFamily := NewFamily("CascadedStatesFamily",IsCascadedState);
CascadedStateRepresentation := NewRepresentation(
                                       "CascadedStateRepresentation",
                                       IsComponentObjectRep,["coords","cstr"]);
CascadedStateType := NewType(CascadedStateFamily,
                             IsCascadedState and CascadedStateRepresentation);

#creating type info for abstract states
AbstractCascadedStateFamily := NewFamily("AbstractCascadedStateFamily",
                                       IsAbstractCascadedState);
AbstractCascadedStateRepresentation :=
    NewRepresentation("AbstractCascadedStateRepresentation",
    CascadedStateRepresentation,[]);
AbstractCascadedStateType := NewType(AbstractCascadedStateFamily,
                             IsAbstractCascadedState and
                             AbstractCascadedStateRepresentation);