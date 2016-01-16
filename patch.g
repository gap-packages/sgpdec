# PATCH: hash function for boolean lists until Orb has a proper one
################################################################################
# Hash function for blists - salvaged from Citrus

if not IsBound(HASH_FUNC_FOR_BLIST) then
  Display("Patching HASH_FUNC_FOR_BLIST with old function.");
  HASH_FUNC_FOR_BLIST :=  function(v, data)
    return ORB_HashFunctionForIntList(ListBlist([1..Length(v)], v), [101,data]);
  end;

  InstallMethod(ChooseHashFunction, "for blist and pos. int.",
          [IsBlistRep, IsPosInt],
   function(p, hashlen)
    return rec(func := HASH_FUNC_FOR_BLIST, data := hashlen);
  end);
else
  Display("No need to patch HASH_FUNC_FOR_BLIST.");
fi;
