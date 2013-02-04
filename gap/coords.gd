#############################################################################
##
## coords.gd           SgpDec package
##
## Copyright (C) 2008-2012
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## List of integers as coordinates.
##

DeclareGlobalFunction("Concretize");
DeclareGlobalFunction("AllConcreteCoords");
DeclareOperation("AsPoint",[IsDenseList,IsCascadeSemigroup]);
DeclareOperation("AsCoords",[IsInt,IsCascadeSemigroup]);
