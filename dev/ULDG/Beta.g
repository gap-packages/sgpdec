Read("uldg.gd");
Read("uldg.gi");

Print("Delta Graphs - Holonomy Decompositons for Delta(n,m)\n");
for i in [5..13] do
  for j in [2..i] do
    Display([i,j]);
    S := Semigroup(
                 List(DeltaGraph(i,j),
                      x -> TransformationFromElementaryCollapsing(x, i+j-1)));
    Display(HolonomyDecomposition(S));
    Print("\n");
  od;
od;
