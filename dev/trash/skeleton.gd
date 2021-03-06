################################################################################
##
## skeleton.gd           SgpDec package
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##                James D. Mitchell
##
## The skeleton of a transformation semigroup: the set of images of
## the state set under the action of the semigroup, plus some useful
## relations on this image set.
##

###################################################
###SKELETON########################################
###################################################

DeclareInfoClass("SkeletonInfoClass");

#the constructor
DeclareGlobalFunction("Skeleton");
DeclareGlobalFunction("ImageSets");
DeclareGlobalFunction("RepresentativeSet");
DeclareGlobalFunction("RepresentativesOnDepth");
DeclareGlobalFunction("ChangeRepresentativeSet");
DeclareGlobalFunction("AllRepresentativeSets");
DeclareGlobalFunction("IsSubductionEquivalent");
DeclareGlobalFunction("IsSubductionLessOrEquivalent");
DeclareGlobalFunction("SubductionWitness");
DeclareGlobalFunction("ImageWitness");
DeclareGlobalFunction("TilesOf");
DeclareSynonym("HolonomyGroupTiles", TilesOf);
DeclareGlobalFunction("RandomTileChain");
DeclareGlobalFunction("AllTileChainsToSet");
DeclareGlobalFunction("AllTileChains");
DeclareGlobalFunction("NumberOfTileChainsToSet");
DeclareGlobalFunction("DepthOfSkeleton");
DeclareGlobalFunction("TopSet");
DeclareGlobalFunction("DepthOfSet");
DeclareGlobalFunction("HeightOfSet");
DeclareGlobalFunction("SkeletonClasses");
DeclareGlobalFunction("SkeletonClassesOnDepth");
DeclareGlobalFunction("SkeletonClassOfSet");
DeclareGlobalFunction("DotSkeleton");

DeclareInfoClass("SkeletonInfoClass");

# to be reimplemented
DeclareGlobalFunction("ActionMatrix");

#EXPERIMENTAL
DeclareGlobalFunction("WeakControlWords");
