#
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
# Transitions  (i.e. input symbols to the automaton, hence generating the lac operon transformation semigroup)
#
# let lactose deplete and time run...
L0 := Transformation([3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]);

# add lactose
L1 := Transformation([9,10,11,12,13,14,15,16,9,10,11,12,13,14,15,16]);

# clock tick
t := Transformation([4,4,3,3,2,2,1,1,16,12,15,11,14,10,13,9]);

# carrying out a Krohn-Rhodes decomosition of the Lac Operon Automaton
hd := HolonomyDecomposition(Semigroup(L0,L1,t));

# number of levels in the hierarchy
Size(hd);

# structure of groups at each level (assumes only one per level):
StructureDescription(GroupComponentsOnDepth(hd,1)[1]);
StructureDescription(GroupComponentsOnDepth(hd,2)[1]);
StructureDescription(GroupComponentsOnDepth(hd,3)[1]);
StructureDescription(GroupComponentsOnDepth(hd,4)[1]);
StructureDescription(GroupComponentsOnDepth(hd,5)[1]);


# lift the generators to the wreath product
L1_hat := Raise(hd,L1);
t_hat := Raise(hd,t);
L0_hat :=Raise(hd,L0);

# display lifted generators
#Display(L0_hat);
#Display(t_hat);
#Display(L1_hat);
Print("\nLift of L0:\n");
ShowDependencies(DepFuncTableFromCascOp(L0_hat)); 
Print("\nLift of t:\n");
ShowDependencies(DepFuncTableFromCascOp(t_hat)); 
Print("\nLift of L1:\n");
ShowDependencies(DepFuncTableFromCascOp(L1_hat)); 


