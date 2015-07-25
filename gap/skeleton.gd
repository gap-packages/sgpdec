#############################################################################
##
## skeleton.gd           SgpDec package
##
## Copyright (C) 2010-2015
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
DeclareGlobalFunction("TilesContaining");
DeclareGlobalFunction("DepthOfSet");
DeclareGlobalFunction("RepresentativeSet");
DeclareGlobalFunction("RandomChain");
DeclareGlobalFunction("ChainsBetween");
DeclareGlobalFunction("Chains");
DeclareGlobalFunction("ChainRoot");
DeclareGlobalFunction("OnSequenceOfSets");
DeclareGlobalFunction("NrChainsBetween");
DeclareGlobalFunction("DominatingChain");
DeclareGlobalFunction("DominatingChains");
DeclareGlobalFunction("IsSubductionEquivalent");
DeclareGlobalFunction("IsSubductionLessOrEquivalent");
DeclareGlobalFunction("SubductionWitness");
DeclareGlobalFunction("ImageWitness");
DeclareGlobalFunction("SubductionClassOfSet");
DeclareGlobalFunction("RealImageSubductionClasses");
DeclareGlobalFunction("SubductionClasses");
DeclareGlobalFunction("SubductionClassesOnDepth");

DeclareInfoClass("SkeletonInfoClass");

DeclareGlobalFunction("DotChainActions");
DeclareGlobalFunction("TikzChainActions");

#EXPERIMENTAL
DeclareGlobalFunction("WeakControlWords");
