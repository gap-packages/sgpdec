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
#DeclareGlobalFunction("IsEquivalent");
DeclareGlobalFunction("GetIN");
DeclareGlobalFunction("GetINw");
DeclareGlobalFunction("GetOUT");
DeclareGlobalFunction("GetOUTw");
DeclareGlobalFunction("CoveringSetsOf");
DeclareGlobalFunction("RandomCoverChain");
DeclareGlobalFunction("AllCoverChainsToSet");
DeclareGlobalFunction("AllCoverChains");
DeclareGlobalFunction("NumberOfCoverChainsToSet");
DeclareGlobalFunction("DepthOfSkeleton");
DeclareGlobalFunction("TopSet");
DeclareGlobalFunction("DepthOfSet");
DeclareGlobalFunction("HeightOfSet");
DeclareGlobalFunction("SkeletonClasses");
DeclareGlobalFunction("SkeletonClassesOnDepth");
DeclareGlobalFunction("DotSkeleton");
#PERMUTATORS
DeclareGlobalFunction("RoundTripWords");
DeclareGlobalFunction("PermutatorGeneratorWords");
DeclareGlobalFunction("PermutatorGenerators");
DeclareGlobalFunction("PermutatorSemigroup");
DeclareGlobalFunction("PermutatorGroup");
DeclareGlobalFunction("CoverGroup");

# to be reimplemented
DeclareGlobalFunction("ActionMatrix");