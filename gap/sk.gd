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
DeclareAttribute("ForwardOrbit",IsSkeleton);
DeclareAttribute("SkeletonTransversal",IsSkeleton);
DeclareAttribute("ExtendedImageSet",IsSkeleton);
DeclareAttribute("InclusionCoverBinaryRelation",IsSkeleton);
DeclareAttribute("RepSubductionCoverBinaryRelation",IsSkeleton);
DeclareAttribute("Depths",IsSkeleton);
DeclareAttribute("DepthOfSkeleton",IsSkeleton);
DeclareAttribute("Heights",IsSkeleton);

#functions
DeclareGlobalFunction("TilesOf");
DeclareGlobalFunction("DepthOfSet");
DeclareGlobalFunction("RepresentativeSet");
DeclareGlobalFunction("RepresentativeSetsOnDepth");
DeclareGlobalFunction("AllRepresentativeSets");
DeclareGlobalFunction("RandomTileChain");
DeclareGlobalFunction("AllTileChainsToSet");
DeclareGlobalFunction("AllTileChains");
DeclareGlobalFunction("NumberOfTileChainsToSet");

DeclareInfoClass("SkeletonInfoClass");
