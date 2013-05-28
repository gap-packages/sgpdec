TestFLIsomorphism := function(G)
  local isom, FLG,i,rc1,rc2;
  FLG := FLCascadeGroup(G);
  isom := IsomorphismPermGroup(FLG);
  Print("FLG for " , G , "\n");
  if not (G = Image(isom)) then
    Error("The image of FLGroup does not match the original...");
  fi;
  for i in [1..333] do
    rc1 := Random(FLG);
    rc2 := Random(FLG);
    if PreImage(isom, Image(isom, rc1) * Image(isom,rc2)) <> rc1*rc2
       or
       PreImage(isom, Image(isom, rc2) * Image(isom,rc1)) <> rc2*rc1
       then
      Print("FAIL\n");
      Error("FLG operations do not multiply properly!\n");
    else
      Print("#\c");
    fi;
  od;
  Print("\nPASSED\n");
end;