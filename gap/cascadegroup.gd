#############################################################################
##
## cascadegroup.gd           SgpDec package
##
## Copyright (C) 2008-2013
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Groups built as cascade products.
##


DeclareGlobalFunction("CascadeGroup");
DeclareSynonym("IsCascadeGroup", IsGroup and IsPermCascadeCollection);

DeclareProperty("IsListOfPermGroups", IsListOrCollection);

#full cascade group
DeclareProperty("IsFullCascadeGroup", IsCascadeGroup and IsFullCascadeProduct);
DeclareSynonym("IsGroupWreathProduct", IsFullCascadeGroup);
DeclareGlobalFunction("FullCascadeGroup");
DeclareSynonym("GroupWreathProduct", FullCascadeGroup);
