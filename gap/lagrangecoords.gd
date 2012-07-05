#############################################################################
##
## lagrangecoords.gd           SgpDec package  
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
## 2008 University of Hertfordshire, Hatfield, UK
##
## A hierarchical decomposition: Lagrange coordinatization of groups. 
##

DeclareInfoClass("LagrangeDecompositionInfoClass");
DeclareOperation("LagrangeDecomposition",[IsPermGroup,IsList]);
#getting the coset representative corresponding to a group element
DeclareGlobalFunction("Perm2CosetRepr");
#encoding decoding of coset represntatives - points
DeclareGlobalFunction("EncodeCosetReprs");
DeclareGlobalFunction("DecodeCosetReprs");
DeclareGlobalFunction("Perm2CascadedState");
DeclareGlobalFunction("CascadedState2Perm");
DeclareGlobalFunction("LevelKillers");
DeclareGlobalFunction("LevelBuilders");
#access functions
DeclareGlobalFunction("TransversalsOf");
DeclareGlobalFunction("SeriesOf");
DeclareGlobalFunction("ConvertersToCanonicalOf");
DeclareGlobalFunction("ConvertersFromCanonicalOf");
DeclareGlobalFunction("OriginalStateSet");

#TYPE INFO
DeclareCategory("IsLagrangeDecomposition", IsHierarchicalDecomposition);

DeclareRepresentation( "IsLagrangeDecompositionRep",
                       IsHierarchicalDecompositionRep,
                       [ "series",
                         "transversals"] );

LagrangeDecompositionType  := NewType(
    NewFamily("LagrangeDecompositionTypeFamily",IsLagrangeDecomposition),
    IsLagrangeDecomposition and IsLagrangeDecompositionRep);