#############################################################################
##
## cascadeshell.gd           SgpDec package
##
## Copyright (C) 2008-2012
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## An empty shell defined by an ordered list of components.
## Used for defining cascade structures.
##

DeclareGlobalFunction("CascadeSemigroup");
DeclareCategoryCollections("IsCascade");
DeclareSynonymAttr("IsCascadeSemigroup", IsSemigroup and
        IsCascadeCollection);

DeclareProperty("IsListOfPermGroupsAndTransformationSemigroups",
        IsListOrCollection);
DeclareAttribute("ComponentDomainsOfCascadeSemigroup", IsCascadeSemigroup);
DeclareAttribute("ComponentsOfCascadeSemigroup", IsCascadeSemigroup);
DeclareAttribute("DomainOfCascadeSemigroup", IsCascadeSemigroup);
DeclareAttribute("PrefixDomainOfCascadeSemigroup", IsCascadeSemigroup);
DeclareAttribute("NrDependencyFuncArgs", IsCascadeSemigroup);
DeclareAttribute("NrComponentsOfCascadeSemigroup", IsCascadeSemigroup);

DeclareProperty("IsFullCascadeSemigroup", IsCascadeSemigroup);
DeclareSynonym("IsSemigroupWreathProduct", IsFullCascadeSemigroup);
DeclareGlobalFunction("FullCascadeSemigroup");
DeclareSynonym("SemigroupWreathProduct", FullCascadeSemigroup);

#TO BE REMOVED
DeclareGlobalFunction("AllCoords");
DeclareGlobalFunction("CoordValSets");
DeclareGlobalFunction("NameOfDependencyDomain");
DeclareGlobalFunction("CoordValConverter");
DeclareGlobalFunction("CoordTransConverter");
DeclareGlobalFunction("SizeOfWreathProduct");
DeclareGlobalFunction("NumberOfDependencyFunctionArguments");
