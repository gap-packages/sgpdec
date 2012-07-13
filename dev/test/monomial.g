SGPDEC_TestMonomialGenerators := function(components)
local cstr, mgs, gens,S;
  cstr := CascadedStructure(components);
  mgs := MonomialWreathProductGenerators(cstr);
  Print(Size(mgs), " monomial generators.\n");
  gens := List(mgs, x-> Flatten(x));
  S := Semigroup(gens);
  if (Size(S) <> SizeOfWreathProduct(cstr)) then
    Print("FAIL\n");
    Error("Monomial generators do not generate the wreath product!\n");
  fi;
  Print("Order of wreath product: ", Size(Semigroup(gens)),"\n");
end;
