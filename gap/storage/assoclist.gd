################################################################################
##
## Associative List (declarations)
##
## Copyright (C)  Attila Egri-Nagy
##

DeclareOperation("AssociativeList",[IsList,IsList]);
DeclareGlobalFunction("Assign");
DeclareGlobalFunction("Keys");
DeclareGlobalFunction("CombinedAssociativeList");
DeclareGlobalFunction("ReversedAssociativeList");

#the type info
DeclareCategory("IsAssociativeList", IsDenseList);
#there is a sorted list behind the associative list keys,
#and the corresponding value is stored in values at same index
DeclareRepresentation( "IsAssociativeListRep",IsComponentObjectRep,
        [ "keys", "values"] );
AssociativeListType  :=
  NewType(NewFamily("AssociativeListFamily",IsAssociativeList),
          IsAssociativeList and IsAssociativeListRep);