#LoadPackage("sgpdec");
Read("uldg.gd");
Read("uldg.gi");

Print("Theta Graphs - Holonomy Decompositons \n");
i:=6; j:=5; m:=3;

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

 word1 :=[];
 for c in Reversed([2..i]) do
      Add(word1,[c-1,c]);
      od;
 Add(word1,[i,1]);


word2 :=[];
for c in Reversed([i-m+1..i]) do 
  Add(word2,[c-1,c]);
    od;
  Add(word2,[NumNodes,i-m]);

 if i+1 = NumNodes then Add(word2,[NumNodes-1,NumNodes]); fi; 
 if i+1 < NumNodes then  
     for c in Reversed([i+1..NumNodes])
         do Add(word2,[c-1,c]);
        od;
 fi;

#post multiply by idempotent that occurs as initial generator in word1 and word2
 Add(word1,[i-1,i]);
 Add(word2,[i-1,i]);

w1 := List(word1, x-> TransformationFromElementaryCollapsing(x,NumNodes));
w2 := List(word2, x-> TransformationFromElementaryCollapsing(x,NumNodes));

g1 := w1[1];
g2 := w2[1];
for u in [2..Length(w1)] do g1:=g1*w1[u]; od;
for u in [2..Length(w2)] do g2:=g2*w2[u]; od;

TopGroup :=SemigroupByGenerators([g1,g2]);
Splash(DotSemigroupAction(TopGroup,[1..NumNodes],OnPoints));

Display(LinearNotation(g1));
Display(LinearNotation(g2));

hd2:= HolonomyDecomposition(TopGroup);
 Splash(DotSkeleton(SkeletonOf(hd2),rec()));

 
  #  Splash(DotSkeleton(SkeletonOf(hd))));
si := Size(SemigroupByGenerators([g1,g2])); 
if si= Factorial(NumNodes-1)/2 and i mod 2 = 0 and j mod 2 =0 then Print("Alternating Group A",NumNodes-1,"\n"); 
elif  si = Factorial(NumNodes-1) then Print("Symmetric Group S",NumNodes-1,"\n"); else Print("Size: ",si,"\n"); fi;
if (i=j and m=i-1) then Print("Cycle Graph"); fi;
    Print("\n *** \n");


a := (1,2,3,4,6); b := (3,4,6,7);
 TG := GroupByGenerators([a,b]);
Transitivity(TG);  # It's 3-transitive
A7 :=AlternatingGroup(7);
Intersection(A7,TG);
#TG is not contained in A7 in S7
#but it has no 3-cycles
for i in TG do Display(i); 
od;
a1 := (1,2,3,4,5); b1 := (3,4,5,6);
TG1:=GroupByGenerators([a1,b1]);
A6 := AlternatingGroup(6);
Intersection(A6,TG1);



