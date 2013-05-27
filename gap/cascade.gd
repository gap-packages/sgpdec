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

DeclareCategory("IsCascade", IsMultiplicativeElementWithOne 
        and IsAssociativeElement and IsAttributeStoringRep 
        and IsMultiplicativeElementWithInverse);
DeclareCategory("IsPermCascade", IsCascade);
DeclareCategory("IsTransCascade", IsCascade);

BindGlobal("PermCascadeFamily",
        NewFamily("PermCascadeFamily",
                IsPermCascade, CanEasilySortElements, CanEasilySortElements));

BindGlobal("TransCascadeFamily",
        NewFamily("TransCascadeFamily",
                IsTransCascade, CanEasilySortElements, CanEasilySortElements));

BindGlobal("PermCascadeType", NewType(PermCascadeFamily, IsPermCascade));

BindGlobal("TransCascadeType", NewType(TransCascadeFamily, IsTransCascade));


#constructors
#DeclareGlobalFunction("CascadeNC"); # TODO checking and NC version later
DeclareGlobalFunction("Cascade");
DeclareGlobalFunction("CreateCascade");
DeclareGlobalFunction("IdentityCascade");
DeclareGlobalFunction("RandomCascade");
DeclareOperation("AsCascade", [IsTransformation, IsDenseList]);

#accessing cascade internals
DeclareAttribute("DomainOf", IsCascade);
DeclareAttribute("DependencyFunctionsOf", IsCascade);
DeclareAttribute("NrComponents",IsCascade);
DeclareAttribute("NrDependenciesOfCascade",IsCascade);
DeclareAttribute("ComponentDomains",IsCascade);
DeclareAttribute("DependencyDomainsOf",IsCascade);
DeclareAttribute("NrDependencyFuncArgs", IsCascade);
DeclareGlobalFunction("DependenciesOfCascade");

#the action on coordinates
DeclareGlobalFunction("OnCoordinates");

#drawing
DeclareGlobalFunction("DotCascade");
