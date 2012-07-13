######################################################
TestCascadedInverses := function(csh)
local i,id,rnd,irnd;
  if not IsCascadedGroupShell(csh) then
    Print("# Not a group cascade! no test done!\n"); return;
  fi;
  id := IdentityCascadedOperation(csh);
  Print("Cascaded permutations inverted and ");
  Print("checked whether the inverse is really the inverse.\n");
  for i in [1..ITER] do
    rnd := RandomCascadedOperation(csh,
                   MaximumNumberOfElementaryDependencies(csh));
    irnd := Inverse(rnd);
    if ((rnd*irnd) <> id) or (id <> (irnd*rnd)) then
      Print("FAIL\n");Error("Inverses do not give identity!\n");
    else
      Print("#\c");
    fi;
  od;
  Print("\nPASSED\n");
end;;