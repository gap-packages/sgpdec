#############################################################################
##
## words.gd           SgpDec package
##
## Copyright (C) 2010-2022
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Algorithms with words.
##

#words consisting of positive integers only (no inverse operation)
DeclareGlobalFunction("BuildByWord"); # TODO the Semigroups package has EvaluateWord, check whether we can use taht or we need this more general function
DeclareGlobalFunction("TrajectoryByWord");
DeclareGlobalFunction("IsStraightWord");
DeclareGlobalFunction("Reduce2StraightWord");
DeclareGlobalFunction("RandomWord");

#enumerating straight words
DeclareGlobalFunction("StraightWords");
#SWPs straight word processors
DeclareGlobalFunction("SWP_Printer");
DeclareGlobalFunction("SWP_SimpleCollector");
DeclareGlobalFunction("SWP_WordPointPairCollector");
DeclareGlobalFunction("SWP_Search");
