#############################################################################
##
## words.gd           SgpDec package
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Algorithms with words.
##

#words consisting of positive integers only (no inverse operation)
DeclareGlobalFunction("Construct");
DeclareGlobalFunction("Trajectory");
DeclareGlobalFunction("IsStraightWord");
DeclareGlobalFunction("Reduce2StraightWord");
DeclareGlobalFunction("RandomWord");

#words containing negative values (-i coding the inverse of i)
DeclareGlobalFunction("ConstructWithInverses");
DeclareGlobalFunction("TrajectoryWithInverses");
DeclareGlobalFunction("Reduce2StraightWordWithInverses");
DeclareGlobalFunction("InvertPermutationWord");
DeclareGlobalFunction("ReducePermutationWord");
DeclareGlobalFunction("RandomWordWithInverses");
DeclareGlobalFunction("AugmentWithInverses");
DeclareGlobalFunction("DecodeAugmentedInverses");

#enumerating straight words
DeclareGlobalFunction("AllStraightWords");
DeclareGlobalFunction("StraightWords");
#straight word processors
DeclareGlobalFunction("SWP_Print");

DeclareInfoClass("StraightWordsInfoClass");
