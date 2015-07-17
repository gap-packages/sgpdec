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

DeclareGlobalFunction("RepTile");
DeclareGlobalFunction("RealTile");
DeclareGlobalFunction("EncodeChain");
DeclareGlobalFunction("PositionedChain");
DeclareGlobalFunction("DecodeCoords");
DeclareGlobalFunction("ChangeCoveredSet");
DeclareGlobalFunction("HolonomyInts2Sets");
DeclareGlobalFunction("HolonomySets2Ints");
DeclareGlobalFunction("Interpret");
DeclareAttribute("SkeletonOf", IsHolonomyCascadeSemigroup);
DeclareGlobalFunction("HolonomyComponentActions");
DeclareGlobalFunction("OldHolonomyComponentActions");
DeclareGlobalFunction("HolonomyCascadeSemigroup");
DeclareGlobalFunction("HolonomyRelationalMorphism");
DeclareGlobalFunction("SetwiseProduct");
#TODO, put these back as synonyms
#DeclareGlobalFunction("UnderlyingSetsForHolonomyGroups");
#DeclareGlobalFunction("UnderlyingSetsForHolonomyGroupsOnDepth");

DeclareGlobalFunction("AsHolonomyCascade");
DeclareGlobalFunction("AsHolonomyTransformation");

DeclareInfoClass("HolonomyInfoClass");
