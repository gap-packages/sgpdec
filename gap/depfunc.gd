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
DeclareCategory("IsDependencyFunc", IsRecord);

BindGlobal("DependencyFunctionFamily",
        NewFamily("DependencyFunctionFamily",
                IsDependencyFunc,CanEasilySortElements,CanEasilySortElements));

BindGlobal("DependencyFunctionType", NewType(DependencyFunctionFamily,
        IsDependencyFunc and IsAssociativeElement));

DeclareGlobalFunction("DependencyDomains");
#when you make it from dependencies
DeclareGlobalFunction("DependencyFunction");
DeclareGlobalFunction("Dependencies");
# this is more technical when you know the internals
DeclareGlobalFunction("CreateDependencyFunction");
DeclareGlobalFunction("OnDepArg");
DeclareGlobalFunction("Deps2DepFuncs");
DeclareAttribute("NrDependencies",IsDependencyFunc);
