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

#constructors
DeclareGlobalFunction("CascadeNC");
DeclareGlobalFunction("Cascade");
DeclareGlobalFunction("CreateCascade");
DeclareGlobalFunction("IdentityCascade");
DeclareGlobalFunction("RandomCascade");
DeclareOperation("AsCascade", [IsTransformation, IsDenseList]);

#accessing cascade internals
DeclareAttribute("DomainOf", IsCascade);
DeclareAttribute("DependencyFunctionsOf", IsCascade);
DeclareAttribute("NrComponentsOfCascade",IsCascade);
DeclareAttribute("NrDependenciesOfCascade",IsCascade);
DeclareAttribute("ComponentDomains",IsCascade);
DeclareAttribute("DependencyDomainsOf",IsCascade);
DeclareAttribute("NrDependencyFuncArgs", IsCascade);
DeclareGlobalFunction("DependenciesOfCascade");

#the action on coordinates
DeclareGlobalFunction("OnCoordinates");

#drawing
DeclareGlobalFunction("DotCascade");
