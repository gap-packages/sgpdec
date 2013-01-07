#############################################################################
##
## decomposition.gd           SgpDec package
##
## (C) Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## 2008-2012
##
## The abstract datatype for hierarchical decompositions.
##

DeclareCategory("IsHierarchicalDecomposition", IsDenseList);
DeclareRepresentation( "IsHierarchicalDecompositionRep",
                       IsComponentObjectRep,
                       [ "original",
                         "cascadeshell"] );

DeclareGlobalFunction("OriginalStructureOf");
DeclareOperation("CascadeShellOf",[IsObject]);
#these will be cut from here
DeclareOperation("Interpret",[IsHierarchicalDecomposition,IsInt,IsInt]);
DeclareOperation("ComponentActions",
        [IsHierarchicalDecomposition,IsObject,IsObject]);
DeclareOperation("x2y",[IsHierarchicalDecomposition,IsObject,IsObject]);