#############################################################################
##
## cascadeshell.gd           SgpDec package
##
## Copyright (C) 2008-2012
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## An empty shell defined by an ordered list of components.
## Used for defining cascaded structures.
##

DeclareGlobalFunction("CascadeProduct");
DeclareCategoryCollections("IsCascadedTransformation");
DeclareSynonymAttr("IsCascadeProduct", IsSemigroup and
        IsCascadedTransformationCollection);

DeclareProperty("IsListOfPermGroupsAndTransformationSemigroups",
        IsListOrCollection);
DeclareAttribute("DomainsOfCascadeProductComponents", IsCascadeProduct);
DeclareAttribute("CascadeProductComponents", IsCascadeProduct);
DeclareAttribute("DomainOfCascadeProduct", IsCascadeProduct);

DeclareGlobalFunction("AllCoords");
DeclareGlobalFunction("CoordValSets");
DeclareGlobalFunction("NameOfDependencyDomain");
DeclareGlobalFunction("CoordValConverter");
DeclareGlobalFunction("CoordTransConverter");
DeclareGlobalFunction("SizeOfWreathProduct");
DeclareGlobalFunction("NumberOfDependencyFunctionArguments");