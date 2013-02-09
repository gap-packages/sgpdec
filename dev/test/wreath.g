################################################################################
#testing the full cascade (semi)group

Read("namedgroups.g");

# testing against the stock version of group wreath product
for comps in [[Z2,Z3], [Z3,S4], [S3,Z2],[S5,S6],[D8,S4]] do
  if Size(WreathProduct(comps[2],comps[1]))
     <> Size(FullCascadeSemigroup(comps)) then
    Error("Wreath product size mismatch!");
    return;
  else
    Print("#\c");
  fi;
od;