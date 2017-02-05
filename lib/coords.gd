#############################################################################
##
## coords.gd           SgpDec package
##
## Copyright (C) 2008-2015
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## List of integers as coordinates.
##

DeclareGlobalFunction("Concretize");
DeclareGlobalFunction("AllConcreteCoords");
DeclareOperation("AsPoint",[IsList,IsList,IsList]);
DeclareOperation("AsCoords",[IsPosInt,IsList]);
