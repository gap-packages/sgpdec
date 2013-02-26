################################################################################
#testing the full cascade (semi)group

Read("namedgroups.g");

# testing size against the stock version of group wreath product
pairs := [[Z2,Z3], [Z3,S4], [S3,Z2],[S5,S6],[D8,S4],[S7,S8]];
for comps in Concatenation(pairs, List(pairs, l->Reversed(l))) do
  Print(Name(comps[1]),"wr",Name(comps[2]),"\c");
  if Size(WreathProduct(comps[2],comps[1]))
     <> Size(FullCascadeSemigroup(comps)) then
    Error("Wreath product size mismatch!");
    return;
  else
    Print(" OK\n\c");
  fi;
od;

# testing associativity