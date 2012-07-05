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
