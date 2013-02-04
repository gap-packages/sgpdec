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

DeclareGlobalFunction("CascadeProduct");
DeclareCategoryCollections("IsCascadeTransformation");
DeclareSynonymAttr("IsCascadeProduct", IsSemigroup and
        IsCascadeTransformationCollection);

DeclareProperty("IsListOfPermGroupsAndTransformationSemigroups",
        IsListOrCollection);
DeclareAttribute("DomainsOfCascadeProductComponents", IsCascadeProduct);
DeclareAttribute("ComponentsOfCascadeProduct", IsCascadeProduct);
DeclareAttribute("DomainOfCascadeProduct", IsCascadeProduct);
DeclareAttribute("PrefixDomainOfCascadeProduct", IsCascadeProduct);
DeclareAttribute("NrDependencyFuncArgs", IsCascadeProduct);
DeclareAttribute("NrComponentsOfCascadeProduct", IsCascadeProduct);

#TO BE REMOVED
DeclareGlobalFunction("AllCoords");
DeclareGlobalFunction("CoordValSets");
DeclareGlobalFunction("NameOfDependencyDomain");
DeclareGlobalFunction("CoordValConverter");
DeclareGlobalFunction("CoordTransConverter");
DeclareGlobalFunction("SizeOfWreathProduct");
DeclareGlobalFunction("NumberOfDependencyFunctionArguments");
