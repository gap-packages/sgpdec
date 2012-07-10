######################################################
TestCascadedInverses := function(cascprodinfo)
local i,id,rnd,irnd;
  if not IsCascadedGroup(cascprodinfo) then
    Print("# Not a group cascade! no test done!\n"); return;
  fi;
  id := IdentityCascadedOperation(cascprodinfo);
  Print("Random cascaed permutations inversed and checked against the product identity\n");
  for i in [1..ITER] do
    rnd := RandomCascadedOperation(cascprodinfo,MaximumNumberOfElementaryDependencies(cascprodinfo));
    irnd := Inverse(rnd);
    if ((rnd*irnd) <> id) or (id <> (irnd*rnd)) then
      Print("FAIL\n");Error("Inverses do not give identity!\n");
    else
      Print("#\c");
    fi;
  od;
  Print("\nPASSED\n");
end;;