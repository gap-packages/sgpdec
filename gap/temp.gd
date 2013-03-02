if not IsBound(EnumeratorOfCartesianProduct) then
  DeclareOperation("TransformationOp", [IsObject, IsList, IsFunction]);
fi;

ISBOUNDENUMERATORCARTESIANPRODUCT := true;
if not IsBound(EnumeratorOfCartesianProduct) then
  ISBOUNDENUMERATORCARTESIANPRODUCT := false;
  DeclareGlobalFunction("EnumeratorOfCartesianProduct");
fi;

ISBOUNDACTIONREPRESENTATIVES := true;
if not IsBound(ActionRepresentatives) then
  ISBOUNDACTIONREPRESENTATIVES := false;
  DeclareAttribute("ActionRepresentatives", IsSemigroup);
fi;
