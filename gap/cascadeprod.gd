#############################################################################
##
## cascadeprod.gd           SgpDec package
##
## Copyright (C) 2008-2013
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Cascade product.
##

DeclareGlobalFunction("CascadeSemigroup");
DeclareCategoryCollections("IsCascade");
DeclareSynonymAttr("IsCascadeSemigroup", IsSemigroup and
        IsCascadeCollection);

DeclareCategoryCollections("IsPermCascade");
DeclareSynonymAttr("IsCascadeGroup", IsGroup and
        IsPermCascadeCollection);


DeclareProperty("IsListOfPermGroupsAndTransformationSemigroups",
        IsListOrCollection);
DeclareAttribute("ComponentDomains", IsCascadeSemigroup);
DeclareAttribute("ComponentsOfCascadeSemigroup", IsCascadeSemigroup);
DeclareAttribute("DomainOf", IsCascadeSemigroup);
DeclareAttribute("NrDependencyFuncArgs", IsCascadeSemigroup);
DeclareAttribute("NrComponentsOfCascadeSemigroup", IsCascadeSemigroup);

DeclareProperty("IsFullCascadeSemigroup", IsCascadeSemigroup);
DeclareSynonym("IsSemigroupWreathProduct", IsFullCascadeSemigroup);
DeclareGlobalFunction("FullCascadeSemigroup");
DeclareSynonym("SemigroupWreathProduct", FullCascadeSemigroup);

DeclareProperty("IsFullCascadeGroup", IsCascadeGroup);
DeclareGlobalFunction("FullCascadeGroup");

#DeclareGlobalFunction("SizeOfWreathProduct");
