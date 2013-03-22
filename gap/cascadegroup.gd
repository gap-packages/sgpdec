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
DeclareCategoryCollections("IsPermCascade");
DeclareSynonymAttr("IsCascadeGroup", IsGroup and
        IsPermCascadeCollection);

DeclareAttribute("ComponentDomains", IsCascadeGroup);
DeclareAttribute("ComponentsOfCascadeGroup", IsCascadeGroup);
DeclareAttribute("DomainOf", IsCascadeGroup);
DeclareAttribute("NrDependencyFuncArgs", IsCascadeGroup);
DeclareAttribute("NrComponentsOfCascadeGroup", IsCascadeGroup);

DeclareProperty("IsFullCascadeGroup", IsCascadeGroup);
DeclareSynonym("IsGroupWreathProduct", IsFullCascadeGroup);
DeclareGlobalFunction("FullCascadeGroup");
DeclareSynonym("GroupWreathProduct", FullCascadeGroup);

DeclareProperty("IsFullCascadeGroup", IsCascadeGroup);
DeclareGlobalFunction("FullCascadeGroup");
