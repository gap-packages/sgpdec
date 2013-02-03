SGPDEC_TestMonomialGenerators := function(components)
local csh, mgs, gens,S;
  csh := CascadeShell(components);
  mgs := MonomialWreathProductGenerators(csh);
  Print(Size(mgs), " monomial generators.\n");
  gens := List(mgs, x-> AsTransformation(x));
  S := Semigroup(gens);
  if (Size(S) <> SizeOfWreathProduct(csh)) then
    Print("FAIL\n");
    Error("Monomial generators do not generate the wreath product!\n");
  fi;
  Print("Order of wreath product: ", Size(Semigroup(gens)),"\n");
end;
