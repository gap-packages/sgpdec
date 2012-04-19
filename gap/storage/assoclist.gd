################################################################################
##
## Associative List (declarations)
##
## Copyright (C)  Attila Egri-Nagy
##

DeclareCategory("IsAssociativeList", IsDenseList);

#there is a sorted list behind the associative list keys,
#and the corresponding value is stored in values at same index
DeclareRepresentation( "IsAssociativeListRep",IsComponentObjectRep,
        [ "keys", "values"] );
AssociativeListType  :=
  NewType(NewFamily("AssociativeListFamily",IsAssociativeList),
          IsAssociativeList and IsAssociativeListRep);

DeclareOperation("AssociativeList",[IsList,IsList]);
DeclareGlobalFunction("Assign");
DeclareGlobalFunction("Keys");