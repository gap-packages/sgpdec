#############################################################################
##
## skeleton.gd           SgpDec package
##
## Copyright (C) 2010-2013
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Skeleton of the semigroup action on a set. Subduction relation,
## equivalence classes, tilechains.
##

DeclareCategory("IsSkeleton", IsObject and IsAttributeStoringRep);
BindGlobal("SkeletonFamily",NewFamily("SkeletonFamily", IsSkeleton));
BindGlobal("SkeletonType", NewType(SkeletonFamily,IsSkeleton));

#constructor
DeclareGlobalFunction("Skeleton");

#stored attributes
DeclareAttribute("TransSgp",IsSkeleton);
DeclareAttribute("BaseSet",IsSkeleton);
DeclareAttribute("Generators",IsSkeleton);
DeclareAttribute("DegreeOfSkeleton",IsSkeleton);
DeclareAttribute("Singletons",IsSkeleton);
DeclareAttribute("NonImageSingletons",IsSkeleton);
DeclareAttribute("NonImageSingletonClasses",IsSkeleton);
DeclareAttribute("ForwardOrbit",IsSkeleton);
DeclareAttribute("SkeletonTransversal",IsSkeleton);
DeclareAttribute("ExtendedImageSet",IsSkeleton);
DeclareAttribute("InclusionCoverBinaryRelation",IsSkeleton);
DeclareAttribute("RepSubductionCoverBinaryRelation",IsSkeleton);
DeclareAttribute("Depths",IsSkeleton);
DeclareAttribute("DepthOfSkeleton",IsSkeleton);
DeclareAttribute("Heights",IsSkeleton);
DeclareAttribute("RepresentativeSets",IsSkeleton);
DeclareGlobalFunction("RepresentativeSetsOnDepth");
PartialOrbits := NewAttribute("PartialOrbits",IsSkeleton,"mutable");
MakeReadOnlyGlobal("PartialOrbits");

#functions
DeclareGlobalFunction("ContainsSet");
DeclareGlobalFunction("TilesOf");
DeclareGlobalFunction("DepthOfSet");
DeclareGlobalFunction("RepresentativeSet");
DeclareGlobalFunction("RandomTileChain");
DeclareGlobalFunction("MaximalChainsBetween");
DeclareGlobalFunction("AllTileChains");
DeclareGlobalFunction("OnSequenceOfSets");
DeclareGlobalFunction("NrTileChainsBetween");
DeclareGlobalFunction("DominatingTileChain");
DeclareGlobalFunction("AllDominatingTileChains");
DeclareGlobalFunction("PositionedTileChain");
DeclareGlobalFunction("IsSubductionEquivalent");
DeclareGlobalFunction("IsSubductionLessOrEquivalent");
DeclareGlobalFunction("SubductionWitness");
DeclareGlobalFunction("ImageWitness");
DeclareGlobalFunction("SubductionClassOfSet");
DeclareGlobalFunction("RealImageSubductionClasses");
DeclareGlobalFunction("SubductionClasses");
DeclareGlobalFunction("SubductionClassesOnDepth");

DeclareInfoClass("SkeletonInfoClass");

#EXPERIMENTAL
DeclareGlobalFunction("WeakControlWords");
