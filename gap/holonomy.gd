#############################################################################
##
## holonomy.gd           SgpDec package
##
## Copyright (C) 2008-2012
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## A hierarchical decomposition: Holonomy coordinatization of semigroups.
##

DeclareOperation("HolonomyDecomposition",[IsTransformationSemigroup]);
DeclareGlobalFunction("SkeletonOf");
DeclareGlobalFunction("GroupComponentsOnDepth");
DeclareGlobalFunction("Coordinates");
DeclareGlobalFunction("CoverChain");
DeclareGlobalFunction("ChangeCoveredSet");
DeclareGlobalFunction("HolonomyInts2Sets");
DeclareGlobalFunction("HolonomySets2Ints");
DeclareGlobalFunction("PermutationResetSemigroup");
DeclareGlobalFunction("ShiftGroupAction");

#TYPE INFO
DeclareCategory("IsHolonomyDecomposition", IsHierarchicalDecomposition);

DeclareRepresentation(
        "IsHolonomyDecompositionRep",
        IsHierarchicalDecompositionRep,
        [ "skeleton", #reference to the full skeleton
          #the followings are here for convenient access for each level
          "reps", #the list of representative sets,
                  #whose covering sets are the states on this level
          "coords", #the tile sets of the representatives
          "allcoords", #cover sets of all reps on one level in one list
          "cascadeshell",
          "groupcomponents"]);#from permutation-reset components, it may not be
                            #straightforward what the group components are

HolonomyDecompositionType  := NewType(
    NewFamily("HolonomyDecompositionTypeFamily",IsHolonomyDecomposition),
    IsHolonomyDecomposition and IsHolonomyDecompositionRep);

DeclareInfoClass("HolonomyInfoClass");
