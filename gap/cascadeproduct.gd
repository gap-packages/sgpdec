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
DeclareProperty("IsFullCascadeProduct", IsCascadeProduct);

DeclareAttribute("ComponentsOfCascadeProduct", IsCascadeProduct);
DeclareAttribute("DomainOf", IsCascadeProduct);

DeclareProperty("IsListOfPermGroupsAndTransformationSemigroups",
        IsListOrCollection);
DeclareAttribute("ComponentDomains", IsCascadeProduct);
