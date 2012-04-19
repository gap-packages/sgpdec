#############################################################################
##
## cascadedstate.gd           SgpDec package  
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
## 2008 University of Hertfordshire, Hatfield, UK
##
## Declarations for  cascaded states.
##

#############################################################################
##
##  <#GAPDoc Label="IsCascadedState">
##  <ManSection><Heading>Types of Cascaded States</Heading>
##  <Filt Name="IsCascadedState" Arg="obj" Type="Category"/>
##  <Filt Name="IsAbstractCascadedState" Arg="obj" Type="Category"/>
##  <Description>
##  Cascaded states are integer lists coding the states of the components 
##  of a cascaded structures coordinatewise. 
##  0 as a coordinate value (displayed as *) means that the coordinate position can be replaced
##  by any state from that component. Therefore cascaded states containing 0
##  at some level represent a set of cascaded states and they are called abstract cascaded states.
##  The abstract states are used for compact enumeration of dependecy mappings (especially in holonomy) but
##  eventually they may be used in the internal algorithms for cascaded structures.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareCategory("IsAbstractCascadedState",IsDenseList); # IsDenseList only because of the Length method. (However it could probably be better integrated.)
DeclareCategory("IsCascadedState",IsAbstractCascadedState);

#######FOR CREATING STATES###############################################
#############################################################################
##  <#GAPDoc Label="CascadedState">
##  <ManSection><Heading>Constructing a cascaded state</Heading>
##  <Func Name="CascadedState" Arg="cascadedstruct,coords"/>
##  <Description>
##   Cascaded states can be constructed only within the context of a cascaded structure
##   (and each cascaded state knows and belongs to only one such structure). 
##    This constructor function checks
##   whether the coordinates form a valid (abstract) cascaded state.
##  <Example>
##  gap> cstr := CascadedStructure([Z2,Z3]);;
##  gap> cs := CascadedState(cstr,[1,3]);
##  C(1,3)
##  gap> acs := CascadedState(cstr,[1,0]);
##  C(1,*) 
##  </Example> 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction("CascadedState");

# returns a representative concrete cascaded state corresponding to an abstract state
DeclareGlobalFunction("Concretize");
