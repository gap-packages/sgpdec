#############################################################################
##
## skeletongroups.gd           SgpDec package
##
## Copyright (C) 2010-2013
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Groups acting on subsets of the state set.
##

InMaps := NewAttribute("InMaps",IsSkeleton,"mutable");
InWords := NewAttribute("InWords",IsSkeleton,"mutable");
OutMaps := NewAttribute("OutMaps",IsSkeleton,"mutable");
OutWords := NewAttribute("OutWords",IsSkeleton,"mutable");
#TODO make them readonly

DeclareGlobalFunction("GetIN");
DeclareGlobalFunction("GetINw");
DeclareGlobalFunction("GetOUT");
DeclareGlobalFunction("GetOUTw");

#PERMUTATORS
DeclareGlobalFunction("RoundTripWords");
DeclareGlobalFunction("NontrivialRoundTripWords");
DeclareSynonym("HolonomyGroupGeneratorWords", NontrivialRoundTripWords);
DeclareGlobalFunction("PermutatorSemigroupElts");
DeclareGlobalFunction("PermutatorGroup");
DeclareGlobalFunction("PermutatorHolonomyHomomorphism");
DeclareGlobalFunction("HolonomyGroup@");
DeclareGlobalFunction("EvalWordInSkeleton");

#holonomy parallel component shifting stuff
DeclareAttribute("GroupComponents", IsSkeleton);
DeclareAttribute("TileCoords", IsSkeleton);
DeclareAttribute("CoordVals", IsSkeleton);
DeclareAttribute("Shifts", IsSkeleton);
DeclareAttribute("HolonomyPermutationResetComponents", IsSkeleton);
