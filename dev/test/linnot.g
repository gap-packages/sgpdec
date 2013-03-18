#on n points
TestLinearNotation :=  function(n)
local i,rnd;
  Print("Checking linear notation on ",n," points...\n");
  for i in [1..ITER] do
    rnd := RandomTransformation(n);
    if rnd <> AsTransformation(LinearNotation(rnd),n) then
      Print("FAIL\n");Error("Linear notation malfunction!\n");
    else
      Print("#\c");
    fi;
  od;
  Print("\nPASSED\n");
end;;
