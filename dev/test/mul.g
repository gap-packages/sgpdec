######################################################
TestMultiplication := function(comps)
local i,id,rc1, rc2, domsizes;
  domsizes := List(ComponentDomains(comps), x-> Size(x));
  Print("Random operations multiplied  (testing =,*, lifting)\n");
  for i in [1..333] do
    rc1 := RandomCascade(comps,13);
    rc2 := RandomCascade(comps,11);
    if (AsTransformation(rc1*rc2)
        <> (AsTransformation(rc1) * AsTransformation(rc2)))
       or
       ((rc2*rc1)
        <> AsCascade(AsTransformation(rc2) * AsTransformation(rc1),domsizes))
       then
      Print("FAIL\n");
      Error("Random operations do not multiply properly!\n");
    else
      Print("#\c");
    fi;
  od;
  Print("\nPASSED\n");
end;;
