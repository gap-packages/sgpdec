#############################################################################
##
## skeletongroups.gd           SgpDec package
##
## Copyright (C) 2010-2023
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Groups acting on subsets of the state set.
##

DeclareGlobalFunction("FromRep");
DeclareGlobalFunction("FromRepw");
DeclareGlobalFunction("ToRep");
DeclareGlobalFunction("ToRepw");

# lookup tables stored as attributes
DeclareAttribute("FromRepLookup", IsSkeleton);
DeclareAttribute("FromRepwLookup", IsSkeleton);
DeclareAttribute("ToRepLookup", IsSkeleton);
DeclareAttribute("ToRepwLookup", IsSkeleton);
DeclareGlobalFunction("ComputeSkeletonNavigationTables");

#PERMUTATORS
DeclareGlobalFunction("RoundTripWords");
DeclareGlobalFunction("NontrivialRoundTripWords");
DeclareSynonym("HolonomyGroupGeneratorWords", NontrivialRoundTripWords);
DeclareGlobalFunction("PermutatorSemigroupElts");
DeclareGlobalFunction("PermutatorGroup");
DeclareGlobalFunction("PermutatorHolonomyHomomorphism");
DeclareGlobalFunction("PermutationResetSemigroup");
DeclareGlobalFunction("HolonomyGroup@");
DeclareGlobalFunction("EvalWordInSkeleton");

#holonomy parallel component shifting stuff
DeclareAttribute("GroupComponents", IsSkeleton);
DeclareAttribute("TileCoords", IsSkeleton);
DeclareAttribute("CoordVals", IsSkeleton);
DeclareAttribute("Shifts", IsSkeleton);
DeclareAttribute("HolonomyPermutationResetComponents", IsSkeleton);

DeclareGlobalFunction("DisplayHolonomyComponents");
