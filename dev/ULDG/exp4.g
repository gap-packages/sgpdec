LoadPackage("sgpdec");
Read("uldg.gd");
Read("uldg.gi");

Print("Theta Graphs - Holonomy Decompositons \n");
#i:=6; j:=6; m:=4;

for i in [3..15] do
  for j in [i..15] do
    for m in [1..Minimum([(i-1),(j-1)])] do

    NumNodes := i + j - (m+1);

    Display([i,j,m]);
    S := Semigroup(
                 List(ThetaGraph(i,j,m),
                      x -> TransformationFromElementaryCollapsing(x, NumNodes)
                      )
                   );
#    hd := HolonomyDecomposition(S);
#f := DotSemigroupAction(S,[1..NumNodes],OnPoints);
#FileString(Concatenation("~/Theta-",String(i),"-",String(j),"-",String(m),".dot"),f);

  Print("Rank of Defect One: ", NumNodes-1,"\n");

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

Display(LinearNotation(g1));
Display(LinearNotation(g2));

Display(HolonomyDecomposition(SemigroupByGenerators([g1,g2])));
 
h1:= PermList(ActionOn(Concatenation([1..i-2],[i..NumNodes]),g1,OnPoints));
h2:= PermList(ActionOn(Concatenation([1..i-2],[i..NumNodes]),g2,OnPoints));

Print("Conjugate of gen1: ");
Display(h1 * h2 *Inverse(h1));
Print("Commutator of gens: ");
Display(h1^m * h2 *Inverse(h1^m) *Inverse(h2));
Display(h1 * h2 *Inverse(h1) *Inverse(h2));
Display(Inverse(h1) * h2 *h1 *Inverse(h2));
Display(Inverse(h1) * Inverse(h2) *h1 *h2);
Display(h2^2 * h1 *Inverse(h2^2) *Inverse(h1));
Display(Inverse(h2^2) * h1 *h2^2 *Inverse(h1));
Display(Inverse(h2^2) * Inverse(h1) *h2^2 *h1);
Display(h1^2 * h2 *Inverse(h1^2) *Inverse(h2));

  #  Splash(DotSkeleton(SkeletonOf(hd))));
si := Size(SemigroupByGenerators([g1,g2])); 
if si= Factorial(NumNodes-1)/2 and i mod 2 = 0 and j mod 2 =0 then Print("Alternating Group A",NumNodes-1,"\n"); 
elif  si = Factorial(NumNodes-1) then Print("Symmetric Group S",NumNodes-1,"\n"); else Print("Size: ",si,"\n"); fi;
if (i=j and m=i-1) then Print("Cycle Graph"); fi;
    Print("\n *** \n");
od;
od;
od;
