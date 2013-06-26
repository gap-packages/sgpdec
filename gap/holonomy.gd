#############################################################################
##
## holonomy.gd           SgpDec package
##
## Copyright (C) 2008-2012
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## A hierarchical decomposition: Holonomy coordinatization of semigroups.
##

DeclareProperty("IsHolonomyCascadeSemigroup",IsCascadeSemigroup);

DeclareGlobalFunction("SetCoordinates");
DeclareGlobalFunction("TileChain");
DeclareGlobalFunction("ChangeCoveredSet");
DeclareGlobalFunction("HolonomyInts2Sets");
DeclareGlobalFunction("HolonomySets2Ints");
DeclareGlobalFunction("AllHolonomyLifts");
DeclareGlobalFunction("Interpret");
DeclareGlobalFunction("HolonomyDecomposition");
DeclareAttribute("SkeletonOf", IsHolonomyCascadeSemigroup);
DeclareGlobalFunction("HolonomyComponentActions");
DeclareGlobalFunction("HolonomyDependencies");
DeclareGlobalFunction("HolonomyCascadeSemigroup");
#TODO, put these back as synonyms
#DeclareGlobalFunction("UnderlyingSetsForHolonomyGroups");
#DeclareGlobalFunction("UnderlyingSetsForHolonomyGroupsOnDepth");

DeclareGlobalFunction("AsHolonomyCascade");
DeclareGlobalFunction("AsHolonomyTransformation");

DeclareInfoClass("HolonomyInfoClass");
