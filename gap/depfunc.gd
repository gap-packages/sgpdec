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
DeclareGlobalFunction("DependencyDomains");
#when you make it from dependencies
DeclareGlobalFunction("DependencyFunction");
# this is more technical when you know the internals
DeclareGlobalFunction("CreateDependencyFunction");