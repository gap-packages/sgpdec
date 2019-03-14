#############################################################################
##
## fl.gd           SgpDec package
##
## Copyright (C) 2008-2019
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Frobenius-Lagrange decomposition. Cascade groups built from components
## acting on coset spaces determined by a subgroup chain.
##

DeclareProperty("IsFLCascadeGroup",IsCascadeGroup);

DeclareOperation("FLCascadeGroup", [IsList, IsPosInt]);

DeclareGlobalFunction("FLComponents");
DeclareGlobalFunction("FLDependencies");
DeclareGlobalFunction("FLComponentActions");
DeclareGlobalFunction("AsFLPoint");
DeclareGlobalFunction("AsFLCoords");
DeclareGlobalFunction("AsFLCascade");
DeclareGlobalFunction("AsFLPermutation");
DeclareGlobalFunction("Perm2Reps");
DeclareGlobalFunction("Perm2Coords");
DeclareGlobalFunction("Coords2Perm");
DeclareGlobalFunction("LevelKillers");
DeclareGlobalFunction("LevelBuilders");
DeclareGlobalFunction("DisplayFLComponents");

DeclareAttribute("TransversalsOf", IsFLCascadeGroup);
DeclareAttribute("BottomCosetActionRepsOf", IsFLCascadeGroup);
DeclareAttribute("StabilizedPoint", IsFLCascadeGroup);
