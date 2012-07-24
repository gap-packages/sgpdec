InstallOtherMethod(WreathProduct, "for transformation semigroups",
        [IsTransformationSemigroup, IsTransformationSemigroup],
function(T1, T2)
local mgs, gens, cstr;
  #note that we start from the top component
  cstr := CascadedStructure([T2, T1]);
  mgs := MonomialWreathProductGenerators(cstr);
  gens := List(mgs, x-> Flatten(x));
  return Semigroup(gens);
end);
