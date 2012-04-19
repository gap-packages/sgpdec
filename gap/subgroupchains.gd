#############################################################################
##
##  subgroupchains.gd           GAP library         Attila Egri-Nagy
##
##  Copyright (C)  2003-2009, Attila Egri-Nagy, Chrystopher L. Nehaniv
##  University of Hertfordshire, Hatfield, UK
##
## Subgroup chains of permutation groups.
##

#=========INTERACTIVE METHODS==================================================

#############################################################################
##
##      <#GAPDoc Label="iCreateSubnormalChain">
##      <ManSection><Heading>Subnormal Chain</Heading>
##      <Func Name="iCreateSubnormalChain" Arg="permgroup"/>
##      <Description>
##      Interactively  constructs a subnormal chain for the given permutation group. 
##      </Description>
##      </ManSection>
##      <#/GAPDoc>
DeclareGlobalFunction("iCreateSubnormalChain");

#############################################################################
##
##      <#GAPDoc Label="iCreateMaximalSubgroupChain">
##      <ManSection><Heading>Maximal Subgroup Chain</Heading>
##      <Func Name="iCreateMaximalSubgroupChain" Arg="permgroup"/>
##      <Description>
##      Interactively  constructs a maximal subgroup chain for the given permutation group. 
##      </Description>
##      </ManSection>
##      <#/GAPDoc>
DeclareGlobalFunction("iCreateMaximalSubgroupChain");

#############################################################################
##
##  <#GAPDoc Label="iStretchSubNormalChain">
##  <ManSection><Heading>Stretcing: Inserting a subgroup into a subnormal chain</Heading>
##  <Func Name="iStretchSubNormalChain" Arg="chain"/>
##  <Description>
##  Interactively  inserts a subgroup into a subnormal chain. Useful when one needs to reduce
##  the number of coordinates on a given level.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction("iStretchSubNormalChain");
