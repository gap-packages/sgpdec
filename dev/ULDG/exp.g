for i in [5..13] do
  for j in [2..i] do
    S := Semigroup(
                 List(DeltaGraph(i,j),
                      x -> TransformationFromElementaryCollapsing(x, i+j-1)));
    Display([i,j]);
    Display(HolonomyDecomposition(S));
  od;
od;