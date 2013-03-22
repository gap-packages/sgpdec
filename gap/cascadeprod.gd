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

DeclareGlobalFunction("SizeOfIteratedTransformationWreathProduct");
