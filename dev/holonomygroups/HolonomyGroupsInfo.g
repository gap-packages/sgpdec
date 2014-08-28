
# Holonomy Groups and Words- by C L Nehaniv, University of Hertfordshire  -  1 July 2013

# adapted to latest SgpDec 4-5 June 2014

# presumes Skeleton is in sk
# presumes generators are in gen

if not IsBound(SgpDecTransitionNames) then SgpDecTransitionNames := List([1..Size(gen)],x->String(x));  fi;
if Size(SgpDecTransitionNames) <> Size(gen) then  SgpDecTransitionNames := List([1..Size(gen)],x->String(x)); fi;
if not IsBound(SgpDecStateNames) then SgpDecStateNames := List([1..Size(BaseSet(sk))],x->String(x));  fi;
if Size(SgpDecStateNames) <> Size(BaseSet(sk)) then  SgpDecStateNames := List([1..Size(BaseSet(sk))],x->String(x)); fi;

#  uncommend the next 5 lines for more verbose output
#Print("Holonomy Groups and Generators");

#Print("Generators of Semigroup: ", gen, "\n");
# for i in [1..Size(gen)] do
#     Print(LinearNotation(gen[i]), " denoted by ", SgpDecTransitionNames[i],"\n");
#     od;

for dx in [1..DepthOfSkeleton(sk)-1] do
#   Print("Representatives at Depth ", dx ,":\n");
   for  x1 in RepresentativeSets(sk)[dx] do
       hx1 := HolonomyGroup@SgpDec(sk,x1); 
       px1 := PermutatorGroup(sk,x1); 
     if IsTrivial(px1)  then
         Print("");
       else Print("\n");
            Print("Depth ", dx, " Image set ", DisplayString(x1), "\n has ");
            x1members :=[];
            for index in [1..Size(BaseSet(sk))] do
               if (x1[index]) then Add(x1members,index); fi; 
               od; 
            Print("Tiles: ");
             for t in  TilesOf(sk,x1) do Print(" ",DisplayString(t)," "); od; 
            Print("\n");
                Print( ", where we denote ");
                   for index in [1..Size(BaseSet(sk))] do
                     if (x1[index]) then  Print(SgpDecStateNames[index]," by ", index, ".\n" ); fi;
                    od; 
              Print("\n");
            Print("Permutator group is ", StructureDescription(px1)," = ",  px1, " : \n");
            Print("Holonomy group is ", StructureDescription(hx1)," = ",  hx1, " : \n");
            map2:= PermutatorHolonomyHomomorphism(sk,x1);  #not needed at the moment
            Print("Permutator Generator Words :\n");
              W := NontrivialRoundTripWords(sk,x1);
               for w in W do #print the permutator generator words using named transitions
                     Print("Generator Word: ");; 
                     if Length(w) = 0 
                      then Print("(empty word)");
                      else Print(Concatenation(List(w,x->SgpDecTransitionNames[x])));
                     fi;
                   trans := EvalWordInSkeleton(sk,w);
                   Print("\n whose transformation is ",LinearNotation(trans),"\n");
                  # p is what the permutator does on the set x1
                 p := AsPermutation(RestrictedTransformation(trans,x1members));    
                  # print what the words do to the tiles as permutations:
 #                 Print(" : "); 
                  Print(" yields permutator ",p," on ",   DisplayString(x1),"\n" );
      #              if Length(w) = 0 
      #                 then Print("(empty word)");
      #                else Print(Concatenation(List(w,x->SgpDecTransitionNames[x])));
      #              fi;
                  h := AsPermutation(TransformationOp(trans,TilesOf(sk,x1),OnFiniteSet));     
                  Print(" inducing holonomy ",h," on its Tiles\n\n");
                  # show what this induces as a permutation of tiles:
     #             Print(" : ", ImageElm(map2,p),"\n\n");  #not needed at the moment
                    od; 
              Print("\n");
   fi;
  od;
od;
