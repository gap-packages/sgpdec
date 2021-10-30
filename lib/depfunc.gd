#############################################################################
##
## depfunc.gd           SgpDec package
##
## (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## 2008-2021
##
## Dependency function.
##

DeclareCategory("IsDependencyFunction", IsRecord);
BindGlobal("DependencyFunctionFamily",
        NewFamily("DependencyFunctionFamily",
                IsDependencyFunction,
                CanEasilySortElements,
                CanEasilySortElements));
BindGlobal("DependencyFunctionType",
        NewType(DependencyFunctionFamily,IsDependencyFunction));

DeclareGlobalFunction("DependencyDomains");
DeclareGlobalFunction("DependencyFunction");
DeclareGlobalFunction("DependencyFunctions");
DeclareGlobalFunction("Dependencies");
DeclareGlobalFunction("DependencyValues");
DeclareGlobalFunction("OnDepArg");
DeclareAttribute("DomainOf", IsDependencyFunction);
DeclareAttribute("NrDependencies",IsDependencyFunction);
