##########################################################################
TestYEAST4Operations :=  function(csh)
local i,rnd;
Print("Random operations flattened-raised  and checked for equality (testing YEAST)\n");
for i in [1..ITER] do
  rnd := RandomCascadedOperation(csh,13);
  if Raise(csh,Flatten(rnd)) <> rnd  then 
      Print("FAIL\n");Error("YEAST malfunction!\n"); 
  else
      Print("#\c");
  fi;
od;
Print("\nPASSED\n");
end;;