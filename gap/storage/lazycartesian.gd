#############################################################################
##
## lazycartesian.gd           SgpDec package  
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
## 2008 University of Hertfordshire, Hatfield, UK
##
## The cartesian product of sets in a list but with lazy evaluation.
##

DeclareCategory("IsLazyCartesian", IsDenseList);

DeclareRepresentation( "IsLazyCartesianRep",
                       IsComponentObjectRep,
                       [ "sets","bases","size" ] );


LazyCartesianType  := NewType(NewFamily("LazyCartesianFamily",IsLazyCartesian),
                              IsLazyCartesian and IsLazyCartesianRep);


#constructor
DeclareGlobalFunction("LazyCartesian");

#DeclareGlobalFunction("LazyCartesianFirstWithPrefix");
#DeclareGlobalFunction("LazyCartesianLastWithPrefix");

