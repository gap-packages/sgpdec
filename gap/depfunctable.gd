#############################################################################
##
## depfunctable.gd           SgpDec package  
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
## 2008 University of Hertfordshire, Hatfield, UK
##
## Functions for handling of tables of dependency functions (to be used in a cascaded operation).
##


#######FOR CREATING STATES###############################################
#############################################################################
##  <#GAPDoc Label="DependencyTable">
## An elementary dependency is simple argument-value pair. For each length (the ith level dependecies) there
## is a list containing the elementary dependencies in parallel lists.
## The dependency table is finally a list containing the ith level dependencies in its ith slot.
##  <#/GAPDoc>

DeclareGlobalFunction("IsStrictlyMoreAbstract");
DeclareGlobalFunction("IsOverlapping");
DeclareGlobalFunction("RegisterNewDependency");
DeclareGlobalFunction("ShowDependencies");
DeclareGlobalFunction("SearchDepFuncTable");
DeclareGlobalFunction("DepFuncTableFromCascOp");
