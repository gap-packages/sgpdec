Read("uldg.gd");
Read("uldg.gi");

Print("Beta Graphs - Holonomy Decompositons \n");
for i in [5..13] do
  for j in [4..i] do
    for m in [0..k] do 
    Display([i,j,m]);
    S := Semigroup(
                 List(MyBetaGraph(i,j,m),
                      x -> TransformationFromElementaryCollapsing(x, i+j-m-1)));
    Display(HolonomyDecomposition(S));
    Print("\n");
   od;
    Print("NEXT\n");
  od;
od;

i:=4, j:=3; m:=2;
   S := Semigroup(
                 List(MyBetaGraph(i,j,m),
                      x -> TransformationFromElementaryCollapsing(x, i+j-m-1)));
    Display(HolonomyDecomposition(S));
