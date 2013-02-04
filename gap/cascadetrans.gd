#############################################################################
##
## cascadetrans.gd           SgpDec package
##
## (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## 2008-2012
##
## Cascade permutations and transformations.
##

DeclareCategory("IsCascadeTransformation", IsMultiplicativeElementWithOne and
IsAssociativeElement and IsAttributeStoringRep);

BindGlobal("CascadeTransformationFamily",
NewFamily("CascadeTransformationFamily",
 IsCascadeTransformation, CanEasilySortElements, CanEasilySortElements));

BindGlobal("CascadeTransformationType", NewType(CascadeTransformationFamily,
 IsCascadeTransformation and IsAssociativeElement));

DeclareGlobalFunction("CascadeTransformationNC");
DeclareGlobalFunction("CascadeTransformation");
DeclareAttribute("DomainOfCascadeTransformation", IsCascadeTransformation);
DeclareAttribute("DependencyFunction", IsCascadeTransformation);
DeclareAttribute("NrComponentsOfCascadeTransformation",
IsCascadeTransformation);
DeclareAttribute("NrDependenciesOfCascadeTransformation",
IsCascadeTransformation);
DeclareAttribute("ComponentDomainsOfCascadeTransformation",
IsCascadeTransformation);
DeclareAttribute("PrefixDomainOfCascadeTransformation",
IsCascadeTransformation);
DeclareAttribute("NrDependencyFuncArgs", IsCascadeTransformation);

DeclareCategory("IsDependencyFunc", IsRecord);
DeclareGlobalFunction("CreateDependencyFunction");
DeclareGlobalFunction("CreateCascadeTransformation");

#old

#DeclareOperation("CascadeShellOf",[IsObject]);

DeclareGlobalFunction("IdentityCascadeTransformation");
DeclareGlobalFunction("OnCoordinates");
DeclareGlobalFunction("RandomCascadeTransformation");
DeclareGlobalFunction("DependencyMapsFromCascadeTransformation");
DeclareGlobalFunction("MonomialWreathProductGenerators");
DeclareGlobalFunction("DotCascadeTransformation");
#DeclareOperation("AsCascadeTrans",[IsMultiplicativeElement,IsCascadeShell]);
#DeclareOperation("AsCascadeTransNC",[IsMultiplicativeElement,IsCascadeShell]);

