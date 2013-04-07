#############################################################################
##
## cascadesemigroup.gd           SgpDec package
##
## Copyright (C) 2008-2013
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Cascade product of semigroups.
##

DeclareGlobalFunction("CascadeSemigroup");
DeclareSynonymAttr("IsCascadeSemigroup", IsSemigroup and IsCascadeProduct);

DeclareProperty("IsFullCascadeSemigroup",
        IsCascadeSemigroup and IsFullCascadeProduct);
DeclareSynonym("IsSemigroupWreathProduct", IsFullCascadeSemigroup);
DeclareGlobalFunction("FullCascadeSemigroup");
DeclareSynonym("SemigroupWreathProduct", FullCascadeSemigroup);

DeclareGlobalFunction("SizeOfIteratedTransformationWreathProduct");
