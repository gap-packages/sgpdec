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
DeclareCategory("IsSkeleton", IsObject);
DeclareRepresentation( "IsSkeletonRep",
        IsComponentObjectRep,
        [ "ts",          #the original transformation semigroup
          "gens",        #the generators of the original ts
          "id",          #the identity element of the original monoid
          "topset",      #the full state set
          "imagesets",   #the set of images
          "imagesetlookup", #image sets to equiv. classes and bus info
          "equivclasses", #imageof equivalence classes
          "inclusion_relation", #inclusion binary relation for points
          "inclusion_hassediag" #inclusion binary relation for points
          ] );
SkeletonType  := NewType(
                         NewFamily("SkeletonFamily",IsSkeleton),
                         IsSkeleton and IsSkeletonRep);

DeclareInfoClass("SkeletonInfoClass");

#the constructor
DeclareOperation("Skeleton",[IsTransformationSemigroup]);

#for the whole skeleton
DeclareGlobalFunction("DepthOfSkeleton");
DeclareGlobalFunction("GeneratorsForSkeleton");
DeclareGlobalFunction("GetTS");
DeclareGlobalFunction("DotSkeleton");
DeclareGlobalFunction("SplashSkeleton");

#the strongly connected components and their reps
DeclareGlobalFunction("SkeletonClasses");
DeclareGlobalFunction("SkeletonClassesOnDepth");
DeclareGlobalFunction("DisplaySkeletonRepresentatives");
DeclareGlobalFunction("IsEquivalent");
DeclareGlobalFunction("ActionMatrix");
DeclareGlobalFunction("RepresentativeSet");
DeclareGlobalFunction("ChangeRepresentativeSet");

#for particular elements of the image set
DeclareGlobalFunction("CoveringSetsOf");
DeclareGlobalFunction("InfoOnSet");
DeclareGlobalFunction("DepthOfSet");
DeclareGlobalFunction("TopSet");
DeclareGlobalFunction("GetEqClass");
DeclareGlobalFunction("GetIN");
DeclareGlobalFunction("GetOUT");





DeclareGlobalFunction("PermutatorGenerators");
DeclareGlobalFunction("Permutators");
DeclareGlobalFunction("PermutatorSemigroup");
DeclareGlobalFunction("AllPermutators");
DeclareGlobalFunction("PermutatorGroup");
DeclareGlobalFunction("CoverGroup");

#ACCESS FUNCTIONS
DeclareGlobalFunction("ImageSets");

#chain related
DeclareGlobalFunction("RandomCoverChain");
DeclareGlobalFunction("AllCoverChainsToSet");
DeclareGlobalFunction("AllCoverChains");
DeclareGlobalFunction("NumberOfCoverChainsToSet");
DeclareGlobalFunction("RandomChain");
DeclareGlobalFunction("AllChainsToSet");
DeclareGlobalFunction("AllChains");
DeclareGlobalFunction("NumberOfChainsToSet");