#############################################################################
##
## decomposition.gd           SgpDec package  
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
## 2008 University of Hertfordshire, Hatfield, UK
##
## The abstract datatype for hierarchical decompositions.
##

DeclareCategory("IsHierarchicalDecomposition", IsDenseList);

DeclareRepresentation( "IsHierarchicalDecompositionRep",
                       IsComponentObjectRep,
                       [ "original",
                         "cascadedstruct"] );

#type info is not needed as it is not instantiated - this is sort of an abstract class


#############ACCESS FUNCTIONS############################################################
#############################################################################
##
##  <#GAPDoc Label="DecompositionAccess">
##  <ManSection><Heading>Accessing hierarchical decomposition internals</Heading>
##  <Func Name="OrignalStructureOf" Arg="decomp"/>
##  <Oper Name="CascadedStructureOf" Arg="object"/>
##  <Description>
##  Access to the original structure and for the resulting cascaded structure.
##  The cascaded structure can be requested from any object which is in relation with a cascaded structure 
##  (cascaded states, cascaded operations, decompositions).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction("OriginalStructureOf");
DeclareOperation("CascadedStructureOf",[IsObject]);

################################################################################################
#the yeast code from travelling in-between the cascade product and the flat algebraic structure#
################################################################################################
# <#GAPDoc Label="Raise">
# <ManSection>
# <Oper Name="Raise" Arg="decomp,element" Comm="lifts the element into the decomposition"/>
# <Description>
# The operation lifts an <Arg>element</Arg> (member of the original structure) into the decomposition structure. It works for both states and operations.
# As the answer is not unique in the general case different calls may return different coordinatizations of the flat element.
# </Description>
# </ManSection>
# <#/GAPDoc>
DeclareOperation("Raise",[IsHierarchicalDecomposition,IsObject]);

# <#GAPDoc Label="Flatten">
#<ManSection>
#   <Oper Name="Flatten" Arg="decomp,cascadedelement" Comm="maps a cascaded element back into the origianl structure"/>
#   <Description>
#    The operation maps a cascaded element (both states and operations) back into the original structure (flat, uncoordinatized).
#   </Description>
#  </ManSection>
# <#/GAPDoc>
DeclareOperation("Flatten",[IsHierarchicalDecomposition,IsObject]);


# <#GAPDoc Label="Interpret">
# <ManSection>
# <Oper Name="Interpret" Arg="decomp,level,state" Comm="the meaning of a state of a component in the context of the original"/>
# <Description>
# This method shows the 'meaning' of a state of a component of the decomposition in the context of the original structure. Basically, this answers questions like, 'We have 3 states on the second level, but what do they correspond to?'.
# </Description>
# </ManSection>
# <#/GAPDoc>
DeclareOperation("Interpret",[IsHierarchicalDecomposition,IsInt,IsInt]);

# <#GAPDoc Label="ComponentActions">
# <ManSection>
# <Oper Name="ComponentActions" Arg="decomp,operation,state" Comm=""/>
# <Description>
# The actions in the components when for a flat element (permutation or transformation)
#  acts on a cascaded state. Usually lifting an operation into a cascaded operation
#  involves calculating these component actions. 
# </Description>
# </ManSection>
# <#/GAPDoc>
DeclareOperation("ComponentActions",[IsHierarchicalDecomposition,IsObject,IsObject]);

# The answer is always flat.
DeclareOperation("x2y",[IsHierarchicalDecomposition,IsObject,IsObject]);

#############################################################################
##
##  <#GAPDoc Label="DependencyClassesOfDecomposition">
##  <ManSection><Heading>Classifying Dependency Types</Heading>
##  <Func Name="DependencyClassesOfDecomposition" Arg="decomp"/>
##  <Description>
##  Clusters the elements of a decomposition's original structure
##   according to their dependency graph.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction("DependencyClassesOfDecomposition");
