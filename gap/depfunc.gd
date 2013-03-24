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
#when you make it from dependencies
DeclareGlobalFunction("DependencyFunction");
DeclareGlobalFunction("Dependencies");
# this is more technical when you know the internals
DeclareGlobalFunction("CreateDependencyFunction");
DeclareGlobalFunction("OnDepArg");
DeclareGlobalFunction("Deps2DepFuncs");
DeclareAttribute("DomainOf", IsDependencyFunction);
DeclareAttribute("NrDependencies",IsDependencyFunction);
