Read("uldg.gd");
Read("uldg.gi");

Print("Beta Graphs - Holonomy Decompositons \n");
for i in [5..13] do
  for j in [4..i] do
    for m in [0..2] do 
    Display([i+m,j+m,m]);
    S := Semigroup(
                 List(ThetaGraph(i+m,j+m,m),
                      x -> TransformationFromElementaryCollapsing(x, i+j+2*m-m-1)));
    Display(HolonomyDecomposition(S));
    Print("\n");
   od;
    Print("NEXT\n");
  od;
od;
