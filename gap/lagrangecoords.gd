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

#TYPE INFO
DeclareCategory("IsLagrangeDecomposition", IsHierarchicalDecomposition);

DeclareRepresentation( "IsLagrangeDecompositionRep",
                       IsHierarchicalDecompositionRep,
                       [ "series",
                         "transversals"] );

LagrangeDecompositionType  := NewType(
    NewFamily("LagrangeDecompositionTypeFamily",IsLagrangeDecomposition),
    IsLagrangeDecomposition and IsLagrangeDecompositionRep);

DeclareInfoClass("LagrangeDecompositionInfoClass");

#CONSTRUCTOR

#############################################################################
##
##      <#GAPDoc Label="LagrangeDecomposition">
##      <ManSection><Heading>Lagrange Decomposition</Heading>
##      <Oper Name="LagrangeDecomposition" Arg="permgroup"/>
##      <Oper Name="LagrangeDecomposition" Arg="permgroup, subgroupchain"/>
##      <Description>
##      <C>LagrangeDecomposition</C> constructs a hierarchical decomposition for a permutation 
##      group based on a chain of subgroups of G. 
##      If the chain is not specified, &GAP;'s <C>ChiefSeries</C> is used to calculate the chain.
##      <Example>
##  S4 := SymmetricGroup(IsPermGroup, 4);
##  ld := LagrangeDecomposition(S4);
##      </Example> 
##      </Description>
##      </ManSection>
##      <#/GAPDoc>
DeclareOperation("LagrangeDecomposition",[IsPermGroup,IsList]);


#getting the coset representative corresponding to a group element
DeclareGlobalFunction("Perm2CosetRepr");

#encoding decoding of coset represntatives - points
DeclareGlobalFunction("EncodeCosetReprs");
DeclareGlobalFunction("DecodeCosetReprs");

DeclareGlobalFunction("Perm2CascadedState");
DeclareGlobalFunction("CascadedState2Perm");

#############################################################################
##
##      <#GAPDoc Label="LevelKillers">
##      <ManSection><Heading>Killing coordinates</Heading>
##      <Func Name="LevelKillers" Arg="decomp, cascadedstate"/>
##      <Description>
##      <C>LevelKillers</C> returns a list of cascaded operations, one for each level.
##      Applied top-down (i.e. from index 1 to n) it transforms the coordinate value to 
##      the base value 1.
##      </Description>
##      </ManSection>
##      <#/GAPDoc>
DeclareGlobalFunction("LevelKillers");
DeclareGlobalFunction("LevelBuilders");

#access functions
#############################################################################
##
##      <#GAPDoc Label="LagrangeAccess">
##      <ManSection><Heading>Accessing Lagrange decomposition internals</Heading>
##      <Func Name="SeriesOf" Arg="lagrangedecomp"/>
##      <Func Name="TransversalsOf" Arg="lagrangedecomp"/>
##      <Func Name="ConvertersToCanonicalOf" Arg="lagrangedecomp"/>
##      <Func Name="ConvertersFromCanonicalOf" Arg="lagrangedecomp"/>
##      <Description>
##      Access to the underlying series, and for each level to the transversals, 
##      and functions doing the canonical coding, in a Lagrange decomposition.      
##      </Description>
##      </ManSection>
##      <#/GAPDoc>
DeclareGlobalFunction("TransversalsOf");
DeclareGlobalFunction("SeriesOf");
DeclareGlobalFunction("ConvertersToCanonicalOf");
DeclareGlobalFunction("ConvertersFromCanonicalOf");
DeclareGlobalFunction("OriginalStateSet");



