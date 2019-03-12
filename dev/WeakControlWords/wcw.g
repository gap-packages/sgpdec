
# WeakControl Group  Digraph    - by C L Nehaniv, Univ#
# Algebraic Analysis follows of Lac Operon using SGPDEC  by Attila Egri-Nagy & Chrystopher L. Nehaniv, University of Hertfordshire, using 
# S. Kaufmann's Boolean Network Model, following the journal article
# A. Egri-Nagy & C. L. Nehaniv "Hierarchical Coordinate Systems for Understanding Complexity and Its Evolution, 
# with Applications to Genetic Regulatory Networks", Artificial Life (Special Issue # on Evolution of Complexity), 14(3):299-312, 2008.  [ISSN: 1064-5462]
#
# Binary Variables defining state of system:
# A = Allolactose Present, Op = Operator bound by Repressor (I think), ZYA = Enzymes being produced to metabolize lactose
# L = Lactose present,   value= 1 if true / present, else 0.
# 
# 16 states 
#
#        L A Op ZYA
#  1.    0 0  0  0
#  2.    0 0  0  1
#  3.    0 0  1  0
#  4.    0 0  1  1
#  5.    0 1  0  0
#  6.    0 1  0  1
#  7.    0 1  1  0
#  8.    0 1  1  1
#  9.    1 0  0  0
# 10.    1 0  0  1
# 11.    1 0  1  0
# 12.    1 0  1  1
# 13.    1 1  0  0
# 14.    1 1  0  1
# 15.    1 1  1  0
# 16.    1 1  1  1
#(Remark: state number is  given by 1 + binary vector interpreted base 2):
#
SgpDecStateNames := ["0","ZYA", "Op", "Op ZYA", "A","A ZYA","A Op","A Op ZYA", "L", "L ZYA", "L Op", "L Op ZYA", "L A", "L A ZYA", "L A Op", "L A Op ZYA"];
#
# Transitions  (i.e. input symbols to the automaton, hence generating the lac operon transformation semigroup)
#
# let lactose deplete and time run...
L0 := Transformation([3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]);

# add lactose
L1 := Transformation([9,10,11,12,13,14,15,16,9,10,11,12,13,14,15,16]);

# clock tick
t := Transformation([4,4,3,3,2,2,1,1,16,12,15,11,14,10,13,9]);

SgpDecTransitionNames := ["L0 ","L1 ", "t"];

LAC := Semigroup([L0,L1,t]);
sk := Skeleton(LAC);

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
            Print("Permutator Generator Words :");
              W := NontrivialRoundTripWords(sk,x1);
               for w in W do #print the permutator generator words using named transitions
                  Print(Concatenation(List(w,x->SgpDecTransitionNames[x])),"\n");
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
