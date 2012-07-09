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
                         "cascadedstruct"] );

DeclareGlobalFunction("OriginalStructureOf");
DeclareOperation("CascadedStructureOf",[IsObject]);
DeclareOperation("Raise",[IsHierarchicalDecomposition,IsObject]);
DeclareOperation("Flatten",[IsHierarchicalDecomposition,IsObject]);
DeclareOperation("Interpret",[IsHierarchicalDecomposition,IsInt,IsInt]);
DeclareOperation("ComponentActions",
        [IsHierarchicalDecomposition,IsObject,IsObject]);
DeclareOperation("x2y",[IsHierarchicalDecomposition,IsObject,IsObject]);