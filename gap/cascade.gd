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

#DEPENDENCY FUNCTION
DeclareCategory("IsDependencyFunc", IsRecord);
DeclareGlobalFunction("CreatePrefixDomains");
DeclareGlobalFunction("CreateDependencyFunction");

#CASCADE
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
DeclareAttribute("DomainOfCascade", IsCascade);
DeclareAttribute("DependencyFunction", IsCascade);
DeclareAttribute("NrComponentsOfCascade",IsCascade);
DeclareAttribute("NrDependenciesOfCascade",IsCascade);
DeclareAttribute("ComponentDomains",IsCascade);
DeclareAttribute("PrefixDomainOfCascade",IsCascade);
DeclareAttribute("NrDependencyFuncArgs", IsCascade);
DeclareGlobalFunction("CreateCascade");
DeclareGlobalFunction("IdentityCascade");
DeclareGlobalFunction("OnCoordinates");
DeclareGlobalFunction("RandomCascade");
DeclareGlobalFunction("DependenciesOfCascade");
DeclareGlobalFunction("DotCascade");
