#############################################################################
##
## finiteset.gd           SgpDec package
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
## 2008-2009 University of Hertfordshire, Hatfield, UK
##
## Finite sets of integers.
##

DeclareCategory( "IsFiniteSet", IsListOrCollection );


DeclareRepresentation( "IsFiniteSetBlistRep",
                       IsComponentObjectRep ,
                       [ "blist" ] );

#GLOBAL VARIABLES FOR TYPE INFO
_FiniteSetsFamily :=  NewFamily( "FiniteSetsFamily", IsFiniteSet,
                       CanEasilySortElements, CanEasilySortElements );
_FiniteSetType := NewType( _FiniteSetsFamily,
                          IsFiniteSet and IsFiniteSetBlistRep );
_FiniteSetDomain := Domain(_FiniteSetsFamily,[]);

#constructors
DeclareGlobalFunction("FiniteSet");
DeclareGlobalFunction("FiniteSetByBlist");
#related to size
DeclareGlobalFunction( "SizeOfUniverse" );
DeclareGlobalFunction( "IsSingleton" );
#action on finite sets
DeclareGlobalFunction( "OnFiniteSets" );
DeclareGlobalFunction( "Transf2PermOnSet" );
DeclareGlobalFunction( "IsIdentityOnFiniteSet" );

DeclareGlobalFunction( "IsProperFiniteSubset" );
DeclareGlobalFunction( "UnionFiniteSet" );
DeclareGlobalFunction( "IntersectionFiniteSet" );
DeclareGlobalFunction( "DifferenceFiniteSet" );
DeclareGlobalFunction( "ComplementOfFiniteSet" );

DeclareGlobalFunction("UniteFiniteSet");
DeclareGlobalFunction("UniteFiniteSets");
DeclareGlobalFunction( "IntersectFiniteSet" );
DeclareGlobalFunction( "SubtractFiniteSet" );
DeclareGlobalFunction( "ComplementFiniteSet" );

DeclareGlobalFunction( "AllSubsets" );

DeclareGlobalFunction("FiniteSetPrinter");
DeclareGlobalFunction("FiniteSetID");

DeclareGlobalFunction("MinFiniteSet");
DeclareGlobalFunction("MaxFiniteSet");