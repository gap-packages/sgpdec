#############################################################################
##
## cascadedoperation.gd           SgpDec package
##
## (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## 2008-2012
##
## Cascaded permutations and transformations.
##

DeclareGlobalFunction("IdentityCascadedOperation");
DeclareGlobalFunction("CascadedOperation");
DeclareGlobalFunction("RandomCascadedOperation");
DeclareOperation("DefineCascadedOperation",[IsObject,IsListOrCollection]);
DeclareGlobalFunction("DependencyMapsFromCascadedOperation");
DeclareGlobalFunction("DependsOn");
DeclareGlobalFunction("DependencyGraph");
DeclareGlobalFunction("ProjectedScope");
DeclareGlobalFunction("IsDependencyCompatible");
DeclareGlobalFunction("IsDependencyCompatibleOnPrefix");
DeclareGlobalFunction("DotCascadedOperation");

#we need the 'WithInverse' property to build groups of cascaded
#transformation though not all of them have inverses
DeclareCategory("IsCascadedOperation", IsMultiplicativeElementWithInverse);

CascadedOperationFamily := NewFamily("CascadedOperationFamily",
                                   IsCascadedOperation);
CascadedOperationRepresentation :=
    NewRepresentation("CascadedOperationRepresentation",
    IsComponentObjectRep,["depfunc","cstr"]);

CascadedOperationType := NewType(CascadedOperationFamily,
                                 IsCascadedOperation and
                                 CascadedOperationRepresentation);