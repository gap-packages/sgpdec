
# C L Nehaniv, University of Hertfordshire, June 2013
# Weak Control Words Hierarchy -  Script for Overview


if not IsBound(SgpDecTransitionNames) then SgpDecTransitionNames := []; fi;

for dx in [1..DepthOfSkeleton(sk)-1] do
   for  x1 in RepresentativeSetsOnDepth(sk,dx) do
     px1 := PermutatorGroup(sk,x1);
     hx1 := HolonomyGroup@SgpDec(sk,x1); 
     if IsTrivial(px1)  then
         Print("");
       else Print("\n");
            Print("Edges from ", DisplayString(x1),"  with permutator group ", StructureDescription(px1)," = ",  px1, " : \n");
            Print("  and holonomy group ", StructureDescription(hx1)," = ",  hx1, " : \n");
            Print("Permutator Generator Words :\n");
              W := NontrivialRoundTripWords(sk,x1);
               for w in W do #print the permutator generator words using named transitions
                  Print(Concatenation(List(w,x->SgpDecTransitionNames[x]))," : ");
                  trans := EvalWordInSkeleton(sk,w);
                  Print(LinearNotation(trans), ", where");
                   for index in [1..Size(BaseSet(sk))] do
                     if (x1[index]) then  Print(" ",index ," is ", SgpDecStateNames[index],"." ); fi;
                    od; 
              Print("\n");
             od;
             Print("\n");
               for dy in [dx+1..DepthOfSkeleton(sk)-1] do
                for Y in RepresentativeSetsOnDepth(sk,dy) do
                 pY:=PermutatorGroup(sk,Y);
           if IsTrivial(pY) then
               Print("");
            else
             wcw := WeakControlWords(sk,x1,Y);
             if not wcw = fail then 
              Print(DisplayString(x1), " down to ", DisplayString(Y), " with permutator group ", StructureDescription(pY)," = ", pY, " : \n");
              Print("via  Weak Control Words: ", Concatenation(List(wcw[1],x->SgpDecTransitionNames[x])), " , ", Concatenation(List(wcw[2],x->SgpDecTransitionNames[x])),"\n\n");
             fi;
           fi;
        od;
     od;
   fi;
  od;
od;
