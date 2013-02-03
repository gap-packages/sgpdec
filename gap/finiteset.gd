#############################################################################
##
## finiteset.gd           SgpDec package
##
## Copyright (C) 2008-2012
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Finite sets of integers. Wrapping boolean lists for speed and readability
## purposes
##

#constructors
DeclareGlobalFunction("FiniteSet");
DeclareGlobalFunction("FiniteSetByBlist");
DeclareGlobalFunction("FiniteSetCopy");
#related to size
DeclareGlobalFunction("SizeOfUniverse");
DeclareGlobalFunction("IsSingleton");
#action on finite sets
DeclareGlobalFunction("OnFiniteSets");
DeclareGlobalFunction("IsIdentityOnFiniteSet");
#set operations that create a new set
DeclareGlobalFunction("IsProperFiniteSubset");
DeclareGlobalFunction("UnionFiniteSet");
DeclareGlobalFunction("IntersectionFiniteSet");
DeclareGlobalFunction("DifferenceFiniteSet");
DeclareGlobalFunction("ComplementOfFiniteSet");
#set operations that changes set
DeclareGlobalFunction("UniteFiniteSet");
DeclareGlobalFunction("UniteFiniteSets");
DeclareGlobalFunction("IntersectFiniteSet");
DeclareGlobalFunction("SubtractFiniteSet");
DeclareGlobalFunction("ComplementFiniteSet");

DeclareGlobalFunction("AllSubsets");

DeclareGlobalFunction("FiniteSetPrinter");

DeclareGlobalFunction("MinFiniteSet");
DeclareGlobalFunction("MaxFiniteSet");

DeclareCategory("IsFiniteSet", IsListOrCollection);

DeclareRepresentation("IsFiniteSetBlistRep",
                       IsComponentObjectRep ,
                       [ "blist" ]);

#GLOBAL VARIABLES FOR TYPE INFO
_FiniteSetsFamily :=  NewFamily("FiniteSetsFamily", IsFiniteSet,
                       CanEasilySortElements, CanEasilySortElements);
_FiniteSetType := NewType( _FiniteSetsFamily,
                          IsFiniteSet and IsFiniteSetBlistRep);
_FiniteSetDomain := Domain(_FiniteSetsFamily,[]);
