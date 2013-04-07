#############################################################################
##
## cascadeproduct.gd           SgpDec package
##
## Copyright (C) 2008-2013
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Cascade products. (the general methods)
##

DeclareCategoryCollections("IsCascade");
DeclareSynonymAttr("IsCascadeProduct", IsMagma and IsCascadeCollection);

DeclareAttribute("ComponentsOfCascadeProduct", IsCascadeProduct);
