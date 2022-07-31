#############################################################################
##
#W  semigroup.gd           GAP library         Attila Egri-Nagy
##
#Y  Copyright (C) Attila Egri-Nagy, Chrystopher L. Nehaniv  
##
#Y  2003, University of Hertfordshire, Hatfield, UK
##
##  
##

DeclareGlobalFunction("ConstantTransformation");
DeclareGlobalFunction("S1");
DeclareGlobalFunction("S0");
DeclareGlobalFunction("SI");
DeclareGlobalFunction("IteratedSemigroupDisplay");
DeclareGlobalFunction("LClassesOfDClass");

#############################################################################
##
#F  GetMaximalJClass( <S> )  
##
##  returns the principial factor of J class in semigroup <S>
##
DeclareGlobalFunction("PrincipialFactor");

#############################################################################
##
#F  GetMaximalJClass( <S> )  
##
##  returns the maximal J class of semigroup <S>
##
DeclareGlobalFunction("GetMaximalDClass");

#############################################################################
##
#F  UnionOfStrictlyLessJClasses( <S> , <J> )  
##
##  returns the union of J classes strictly less then <J> in <S>
##
DeclareGlobalFunction("UnionOfStrictlyLessJClasses");

#############################################################################
##
#P  IsLeftSimpleSemigroup( <S> )  
##
##  is `true' if and only if the semigroup has no proper left ideals.
##
DeclareProperty( "IsLeftSimpleSemigroup", IsSemigroup );


