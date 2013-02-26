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
triples := [ [Z2,S3,S4],[Z3,Z2,Z2],[D5,Z4,Z2]];
for comps in  Concatenation(triples, List(triples, l->Reversed(l))) do
  Print(comps,"\c");
  A := comps[1];
  B := comps[2];
  C := comps[3];
  AB := Image(IsomorphismTransformationSemigroup(SemigroupWreathProduct(A,B)));
  BC := Image(IsomorphismTransformationSemigroup(SemigroupWreathProduct(B,C)));
  size := Size(SemigroupWreathProduct([A,B,C]));
  if size <> Size(SemigroupWreathProduct([AB,C]))
     or
     size <> Size(SemigroupWreathProduct([A,BC])) then
    Error("Full cascade product not associative!");
  else
    Print(" OK\n\c");
  fi;
od;