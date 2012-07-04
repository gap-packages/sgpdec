
######################################################
TestInverses := function(cascprodinfo)
local i,id,rnd,irnd;
id := IdentityCascadedOperation(cascprodinfo);
Print("Random permutations inversed and checked against the product identity\n");
for i in [1..ITER] do
  rnd := RandomCascadedOperation(cascprodinfo,13);
  irnd := Inverse(rnd);  
  if ((rnd*irnd) <> id) or (id <> (irnd*rnd)) then 
      Print("FAIL\n");Error("Inverses do not give identity!\n"); 
  else
      Print("#\c");
  fi;
od;
Print("\nPASSED\n");
end;;
