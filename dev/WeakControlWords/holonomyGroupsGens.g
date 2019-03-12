
# Holonomy Groups and Words- by C L Nehaniv, University of Hertfordshire  -  1 July 2013

# presumes Skeleton is in sk
# presumes generators are in gen

if not IsBound(SgpDecTransitionNames) then SgpDecTransitionNames := []; fi;

Print("Holonomy Groups and Generators");

for dx in [1..DepthOfSkeleton(sk)-1] do
   Print("Representatives at Depth ", dx ,":\n");
   for  x1 in RepresentativesOnDepth(sk,dx) do
     hx1 := HolonomyGroup@SgpDec(sk,x1); 
     if IsTrivial(hx1)  then
         Print("");
       else Print("\n");
            Print("Image set ", DisplayString(x1), "\n has ");
            Print("Tiles: ");
             for t in  TilesOf(sk,x1) do Print(" ",DisplayString(t)," "); od; 
            Print("\n");
            Print("and holonomy group ", StructureDescription(hx1)," = ",  hx1, " : \n");
       #     map2:= PermutatorHolonomyHomomorphism(sk,x1);  #not needed at the moment
            Print("Permutator Generator Words :\n");
              W := NontrivialRoundTripWords(sk,x1);
               for w in W do #print the permutator generator words using named transitions
                  Print(Concatenation(List(w,x->SgpDecTransitionNames[x])));
                  # print what the words do to the tiles as permutations:
                  Print(" : "); 
                  trans := BuildByWord(w,gen,Transformation([1..Size(TopSet(sk))]),\*);
      #           p := AsPermutation(TransformationOp(trans,x1,OnPoints)); #action does not work!     
                  h := AsPermutation(TransformationOp(trans,TilesOf(sk,x1),OnFiniteSets));     
                  Print("transformation is ",LinearNotation(trans),"\n");
      #            Print("permutator is ",p,"\n");
                  Print("inducing holonomy ",h,"\n\n");
                  # p is what the permutator does on the set x1
                  # show what this induces as a permutation of tiles:
         #         Print(" : ", ImageElm(map2,p),"\n\n");  #not needed at the moment
                    od; 
              Print("\n");
   fi;
  od;
od;
