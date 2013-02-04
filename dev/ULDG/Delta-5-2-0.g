LoadPackage("sgpdec");
Read("uldg.gd");
Read("uldg.gi");

Print("Theta Graphs - Holonomy Decompositons \n");
i:=5; j:=2; m:=0;

    NumNodes := i + j - (m+1);

    Display([i,j,m]);
    S := Semigroup(
                 List(ThetaGraph(i,j,m),
                      x -> TransformationFromElementaryCollapsing(x, NumNodes)
                      )
                   );
Splash(DotSemigroupAction(S,[1..NumNodes],OnPoints));
  Print("Rank of Defect One: ", NumNodes-1,"\n");


   hd := HolonomyDecomposition(S);
 Splash(DotSkeleton(SkeletonOf(hd),rec()));


