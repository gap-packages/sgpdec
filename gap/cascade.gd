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

DeclareCategory("IsCascade", IsMultiplicativeElementWithOne and
IsAssociativeElement and IsAttributeStoringRep);

BindGlobal("CascadeFamily",
NewFamily("CascadeFamily",
 IsCascade, CanEasilySortElements, CanEasilySortElements));

BindGlobal("CascadeType", NewType(CascadeFamily,
 IsCascade and IsAssociativeElement));

DeclareGlobalFunction("CascadeNC");
DeclareGlobalFunction("Cascade");
DeclareAttribute("DomainOfCascade", IsCascade);
DeclareAttribute("DependencyFunction", IsCascade);
DeclareAttribute("NrComponentsOfCascade",
IsCascade);
DeclareAttribute("NrDependenciesOfCascade",
IsCascade);
DeclareAttribute("ComponentDomainsOfCascade",
IsCascade);
DeclareAttribute("PrefixDomainOfCascade",
IsCascade);
DeclareAttribute("NrDependencyFuncArgs", IsCascade);

DeclareCategory("IsDependencyFunc", IsRecord);
DeclareGlobalFunction("CreateDependencyFunction");
DeclareGlobalFunction("CreateCascade");

#old

#DeclareOperation("CascadeShellOf",[IsObject]);

DeclareGlobalFunction("IdentityCascade");
DeclareGlobalFunction("OnCoordinates");
DeclareGlobalFunction("RandomCascade");
DeclareGlobalFunction("DependencyMapsFromCascade");
DeclareGlobalFunction("MonomialWreathProductGenerators");
DeclareGlobalFunction("DotCascade");