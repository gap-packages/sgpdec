#automatic splashing?
splashing := true;

# Algebraic Analysis follows of Lac Operon using SGPDEC  by Attila Egri-Nagy & Chrystopher L. Nehaniv, University of Hertfordshire, using 
# S. Kaufmann's Boolean Network Model, following the journal article
# A. Egri-Nagy & C. L. Nehaniv "Hierarchical Coordinate Systems for Understanding Complexity and Its Evolution, 
# with Applications to Genetic Regulatory Networks", Artificial Life (Special Issue # on Evolution of Complexity), 14(3):299-312, 2008.  [ISSN: 1064-5462]
#
# Binary Variables defining state of system:
# A = Allolactose Present, Op = Operator bound by Repressor (I think), ZYA = Enzymes being produced to metabolize lactose
# L = Lactose present,   value= 1 if true / present, else 0.

#
#Modified 2019 February 2019 to run with Gap4r7 
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
LACstates := ["0","ZYA", "Op", "Op ZYA", "A", "A ZYA", "A Op", "A Op ZYA",
              "L","L ZYA", "L Op", "L Op ZYA", "L A", "L A ZYA", "L A Op", "L A Op ZYA"];
LACsymbols:=["L0", "L1", "t"];
#
# Transitions  (i.e. input symbols to the automaton, hence generating the lac operon transformation semigroup)
#
# let lactose deplete and time run...
L0 := Transformation([3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]);

# add lactose
L1 := Transformation([9,10,11,12,13,14,15,16,9,10,11,12,13,14,15,16]);

# clock tick
t := Transformation([4,4,3,3,2,2,1,1,16,12,15,11,14,10,13,9]);

LAC := Semigroup(L0,L1,t);

# carrying out a Krohn-Rhodes decomosition of the Lac Operon Automaton
skel_lac := Skeleton(LAC);  

if splashing then
dot_lac := DotSkeleton(skel_lac,rec(states  := LACstates, symbols :=LACsymbols));
Splash(dot_lac);
fi;

DisplayHolonomyComponents(skel_lac);

Display("Displaying skel lac done!");

if splashing then
  # If there is viz without my extension 
  # d:=DotSemigroupAction(LAC,[1..16],OnPoints);

  # If there is viz with my extension (put in gap4r7 viz/gap/dot.gi and dot.gd)
  d:=DotSemigroupActionWithNames(LAC,[1..16],OnPoints,LACstates,LACsymbols);
  Splash(d);
fi;

LAC_Coordinatized:= HolonomyCascadeSemigroup(LAC);
gen := GeneratorsOfSemigroup(LAC_Coordinatized);
Display(gen[1]);
Display(gen[2]);
Display(gen[3]);
if splashing then
  Splash(DotCascade(gen[1]));
  Splash(DotCascade(gen[2]));
  Splash(DotCascade(gen[3]));
fi;

#Size(LAC_Coordinatized);

if splashing then
SplashList(DotRepHolonomyGroups(skel_lac, rec(states  := LACstates, symbols :=LACsymbols)));
SplashList(DotNaturalSubsystems(skel_lac, rec(states  := LACstates, symbols :=LACsymbols)));
fi;

cs := AsHolonomyCoords(1,skel_lac);          # give the state and skeleton as arguments
#[ 1, 1, 3, 3, 9 ]
cs := OnHolonomyCoords(cs, gen[1]);   # applying a cascade transformation these the coordinate form (gen[1] is the lift of L0)#
#[[ 1, 3, 1, 1, 9 ]
cs := OnHolonomyCoords(cs, gen[1]);   # applying it again 
#[[ 1, 3, 1, 1, 9 ]
 
AsHolonomyPoint([ 1, 3, 1, 1, 9 ],skel_lac); # works as  AsPoint as well
     # The Op state   
#To see what subsets the coordinates correspond to :
CoordVals(skel_lac);
#[ [ {1,2,3,4,9,10,11,12,13,14,15,16}, {5}, {6}, {7}, {8} ],  [ {1}, {2}, {3,4,9,10,11,12,13,14,15,16} ], [ {3,9,10,11,12,13,14,15,16}, {4} ], [ {3}, {9,10,11,12,13,14,15,16} ],  [ {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16} ] ]
#so for example the first 1 in [1,1,3,3,9] corresponds to the set {1,2,3,4,9,10,11,12,13,14,15,16}.
