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
DeclareGlobalFunction("FLTransversals");
DeclareGlobalFunction("FLDependencies");
DeclareGlobalFunction("FLComponentActions");
DeclareGlobalFunction("DisplayFLComponents");
DeclareAttribute("TransversalsOf", IsFLCascadeGroup);
DeclareAttribute("BottomCosetActionRepsOf", IsFLCascadeGroup);
DeclareAttribute("StabilizedPoint", IsFLCascadeGroup);
DeclareAttribute("ValidPoints", IsFLCascadeGroup);

DeclareGlobalFunction("AsFLPoint");
DeclareGlobalFunction("AsFLCoords");
DeclareGlobalFunction("AsFLCascade");
DeclareGlobalFunction("AsFLPermutation");

DeclareOperation("Perm2Reps", [IsPerm, IsList]);
DeclareGlobalFunction("Reps2Perm"); # this doesn't need transversals
DeclareOperation("Reps2FLCoords", [IsPermCollection, IsList]);
DeclareOperation("FLCoords2Reps", [IsList, IsList]);
DeclareOperation("Perm2FLCoords", [IsPerm, IsList]);
DeclareOperation("FLCoords2Perm", [IsList, IsList]);
DeclareOperation("LevelKillers",[IsList, IsList]);
DeclareOperation("LevelBuilders", [IsList, IsList]);
