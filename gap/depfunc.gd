#############################################################################
##
## depfunc.gd           SgpDec package
##
## (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## 2008-2012
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
DeclareGlobalFunction("Dependencies");
DeclareGlobalFunction("DependencyValues");
DeclareGlobalFunction("OnDepArg");
DeclareGlobalFunction("Deps2DepFuncs");
DeclareAttribute("DomainOf", IsDependencyFunction);
DeclareAttribute("NrDependencies",IsDependencyFunction);
