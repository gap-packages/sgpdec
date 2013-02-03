

ISBOUNDENUMERATORCARTESIANPRODUCT := true;
if not IsBound(EnumeratorOfCartesianProduct) then
  ISBOUNDENUMERATORCARTESIANPRODUCT := false;
  DeclareGlobalFunction("EnumeratorOfCartesianProduct");
fi;
