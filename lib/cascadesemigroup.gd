#############################################################################
##
## cascadesemigroup.gd           SgpDec package
##
## Copyright (C) 2008-2022
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Cascade product of semigroups.
##

DeclareSynonym("IsCascadeSemigroup", IsSemigroup and IsCascadeCollection);
DeclareSynonym("IsCascadeProduct", IsCascadeSemigroup);

# stored attributes of cascade semigroups
DeclareAttribute("ComponentsOfCascadeProduct", IsCascadeSemigroup);
DeclareAttribute("DomainOf", IsCascadeSemigroup);
DeclareAttribute("ComponentDomains", IsCascadeSemigroup);

# wreath products are full cascade products
DeclareProperty("IsFullCascadeProduct", IsCascadeSemigroup);
DeclareProperty("IsFullCascadeSemigroup",
                IsCascadeSemigroup and IsFullCascadeProduct);
DeclareSynonym("IsSemigroupWreathProduct", IsFullCascadeSemigroup);

# for creating wreath products
DeclareGlobalFunction("MonomialGenerators");
DeclareGlobalFunction("SizeOfFullCascadeProduct");
DeclareGlobalFunction("FullCascadeSemigroup");
DeclareSynonym("SemigroupWreathProduct", FullCascadeSemigroup);


