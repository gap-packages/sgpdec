
##########################################################################
TestYEAST4Operations :=  function(cstr)
local i,rnd;
Print("Random operations flattened-raised  and checked for equality (testing YEAST)\n");
for i in [1..ITER] do
  rnd := RandomCascadedOperation(cstr,13);
  if Raise(cstr,Flatten(rnd)) <> rnd  then 
      Print("FAIL\n");Error("YEAST malfunction!\n"); 
  else
      Print("#\c");
  fi;
od;
Print("\nPASSED\n");
end;;

