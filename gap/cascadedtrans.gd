#############################################################################
##
## cascadedtrans.gd           SgpDec package
##
## (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## 2008-2012
##
## Cascaded permutations and transformations.
##

DeclareGlobalFunction("IdentityCascadedTransformation");
DeclareGlobalFunction("CascadedTransformation");
DeclareGlobalFunction("OnCoordinates");
DeclareGlobalFunction("RandomCascadedTransformation");
DeclareGlobalFunction("DependencyMapsFromCascadedTransformation");
DeclareGlobalFunction("DependsOn");
DeclareGlobalFunction("DependencyGraph");
DeclareGlobalFunction("ProjectedScope");
DeclareGlobalFunction("IsDependencyCompatible");
DeclareGlobalFunction("IsDependencyCompatibleOnPrefix");
DeclareGlobalFunction("MonomialWreathProductGenerators");
DeclareGlobalFunction("DotCascadedTransformation");

#we need the 'WithInverse' property to build groups of cascaded
#transformation though not all of them have inverses
DeclareCategory("IsCascadedTransformation", IsMultiplicativeElementWithInverse);

CascadedTransformationFamily := NewFamily("CascadedTransformationFamily",
                                   IsCascadedTransformation);
CascadedTransformationRepresentation :=
    NewRepresentation("CascadedTransformationRepresentation",
    IsComponentObjectRep,["depfunc","csh"]);

CascadedTransformationType := NewType(CascadedTransformationFamily,
                                 IsCascadedTransformation and
                                 CascadedTransformationRepresentation);