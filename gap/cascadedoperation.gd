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

DeclareCategory("IsCascadedOperation", IsMultiplicativeElement);
#DeclareCategory("IsCascadedPermutation",
#        IsCascadedOperation and IsMultiplicativeElementWithInverse);
#DeclareCategory("IsCascadedTransformation", IsCascadedOperation);