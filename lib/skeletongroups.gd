#############################################################################
##
## skeletongroups.gd           SgpDec package
##
## Copyright (C) 2010-2015
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Groups acting on subsets of the state set.
##

FromRepMaps := NewAttribute("FromRepMaps",IsSkeleton,"mutable");
FromRepWords := NewAttribute("FromRepWords",IsSkeleton,"mutable");
ToRepMaps := NewAttribute("ToRepMaps",IsSkeleton,"mutable");
ToRepWords := NewAttribute("ToRepWords",IsSkeleton,"mutable");
#TODO make them readonly

DeclareGlobalFunction("FromRep");
DeclareGlobalFunction("FromRepw");
DeclareGlobalFunction("ToRep");
DeclareGlobalFunction("ToRepw");

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
