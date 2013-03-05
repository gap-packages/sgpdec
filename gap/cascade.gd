#############################################################################
##
## cascade.gd           SgpDec package
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

DeclareOperation("AsCascade", [IsTransformation, IsCyclotomicCollection]);
DeclareAttribute("DomainOf", IsCascade);
DeclareAttribute("DependencyFunction", IsCascade);
DeclareAttribute("NrComponentsOfCascade",IsCascade);
DeclareAttribute("NrDependenciesOfCascade",IsCascade);
DeclareAttribute("ComponentDomains",IsCascade);
DeclareAttribute("DependencyDomainsOf",IsCascade);
DeclareAttribute("NrDependencyFuncArgs", IsCascade);
DeclareGlobalFunction("CreateCascade");
DeclareGlobalFunction("IdentityCascade");
DeclareGlobalFunction("OnCoordinates");
DeclareGlobalFunction("RandomCascade");
DeclareGlobalFunction("DependenciesOfCascade");
DeclareGlobalFunction("DotCascade");
