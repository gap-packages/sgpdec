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

DeclareCategory("IsCascadedTransformation", IsMultiplicativeElementWithOne and
IsAssociativeElement and IsAttributeStoringRep);

BindGlobal("CascadedTransformationFamily",
NewFamily("CascadedTransformationFamily",
 IsCascadedTransformation, CanEasilySortElements, CanEasilySortElements));

BindGlobal("CascadedTransformationType", NewType(CascadedTransformationFamily,
 IsCascadedTransformation and IsAssociativeElement));

DeclareGlobalFunction("CascadedTransformationNC");
DeclareGlobalFunction("CascadedTransformation");
DeclareAttribute("DomainOfCascadedTransformation", IsCascadedTransformation);
DeclareAttribute("DependencyFunction", IsCascadedTransformation);
DeclareAttribute("ComponentDomainsOfCascadedTransformation",
IsCascadedTransformation);
DeclareAttribute("PrefixDomainOfCascadedTransformation",
IsCascadedTransformation);
DeclareAttribute("NrDependencyFuncArgs", IsCascadedTransformation);

DeclareCategory("IsDependencyFunc", IsRecord);
DeclareGlobalFunction("CreateDependencyFunction");
DeclareGlobalFunction("CreateCascadedTransformation");

#old

DeclareOperation("CascadeShellOf",[IsObject]);

DeclareGlobalFunction("IdentityCascadedTransformation");
DeclareGlobalFunction("OnCoordinates");
DeclareGlobalFunction("RandomCascadedTransformation");
DeclareGlobalFunction("DependencyMapsFromCascadedTransformation");
DeclareGlobalFunction("DependsOn");
DeclareGlobalFunction("DependencyGraph");
DeclareGlobalFunction("ProjectedScope");
DeclareGlobalFunction("MonomialWreathProductGenerators");
DeclareGlobalFunction("DotCascadedTransformation");
#DeclareOperation("AsCascadedTrans",[IsMultiplicativeElement,IsCascadeShell]);
#DeclareOperation("AsCascadedTransNC",[IsMultiplicativeElement,IsCascadeShell]);

