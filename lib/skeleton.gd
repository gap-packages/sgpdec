#############################################################################
##
## skeleton.gd           SgpDec package
##
## Copyright (C) 2010-2023
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Skeleton of the semigroup action on a set. Subduction relation,
## equivalence classes.
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
DeclareAttribute("InclusionCoverRelation",IsSkeleton);
DeclareAttribute("SubductionEquivClassCoverRelation",IsSkeleton);
DeclareAttribute("SubductionEquivClassRelation",IsSkeleton);
DeclareAttribute("Depths",IsSkeleton);
DeclareAttribute("DepthOfSkeleton",IsSkeleton);
DeclareAttribute("Heights",IsSkeleton);
DeclareAttribute("RepresentativeSets",IsSkeleton);
DeclareGlobalFunction("RepresentativeSetsOnDepth");

#functions
DeclareGlobalFunction("SortedExtendedImageSet");
DeclareGlobalFunction("RepresentativeSet");
DeclareGlobalFunction("MakeRepresentative");
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
