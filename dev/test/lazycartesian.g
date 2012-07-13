TestLazyCartesian := function()
local lc,i,t;
  t := Runtime();
  lc := LazyCartesian([
                [1..55],
                ['a','b','c'],
                [1..33],
                ["foo","bar"]
            ]);
  for i in [1..Length(lc)] do
    if (i = PositionCanonical(lc,lc[i])) then
	if (i mod 1000) = 0 then Print("#\c");fi;
    else 
      Print("FAIL\n");Error("Lazy cartesian inconsistent!\n"); 
    fi;
  od;
  Print("PASSED in",Runtime() - t,"ms\n");
end;
