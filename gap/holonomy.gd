#############################################################################
##
## holonomy.gd           SgpDec package  
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
## 2008 University of Hertfordshire, Hatfield, UK
##
## A hierarchical decomposition: Holonomy coordinatization of semigroups.
##

#TYPE INFO
DeclareCategory("IsHolonomyDecomposition", IsHierarchicalDecomposition);

DeclareRepresentation( "IsHolonomyDecompositionRep",
                       IsHierarchicalDecompositionRep,
                       [ "skeleton", #reference to the full skeleton
                         #the followings are here for convenient access for each level
                         "reps", #the list of representative sets,
                                 #whose covering sets are the states on this level
                         "coordinates", #the tile sets of the representatives
                         "flat_coordinates", # all reptile sets on one level in one list
                      
                         "cascadedstruct", #the cascaded structure built from the components
                         "groupcomponents" #from permutation-reset components, it may not be
                                           #straightforward what the group components are
                         ] );

HolonomyDecompositionType  := NewType(
    NewFamily("HolonomyDecompositionTypeFamily",IsHolonomyDecomposition),
    IsHolonomyDecomposition and IsHolonomyDecompositionRep);


DeclareInfoClass("HolonomyInfoClass");

#CONSTRUCTOR

#############################################################################
##  <#GAPDoc Label="HolonomyDecomposition">
##  <ManSection><Heading>Holonomy Decomposition</Heading>
##  <Oper Name="HolonomyDecomposition" Arg="ts"/>
##  <Oper Name="HolonomyDecomposition" Arg="skeleton"/>
##  <Description>
##  <C>HolonomyDecomposition</C> constructs a hierarchical decomposition for a  
##  transformation semigroup or for a skeleton if there is already one calculated.
##  <Example>
## gap> hd := HolonomyDecomposition(FullTransformationSemigroup(5));
## S5
## S4
## S3
## C2
##  </Example> 
## Once the decomposition is calculated we can draw a picture of the holonomy structure using  <Ref Func="Draw"/> or
##  <Ref Func="Splash"/>. There are also possibilities to change some parameters of the 
## output, like replacing the defualt state names which are simply integer numbers with 
## custom names. 
##  <Example>
##  gap>  Splash(hd, rec(states:=["a","b","c","d","e"]));
##  </Example> 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareOperation("HolonomyDecomposition",[IsTransformationSemigroup]);

#############################################################################
##  <#GAPDoc Label="SkeletonOf">
##  <ManSection><Heading>Underlying skeleton</Heading>
##  <Func Name="SkeletonOf" Arg="holdecomp"/>
##  <Description>
##  Returns the underlying <C>Skeleton</C> of the given holonomy decomposition.
##  <Example>
## gap> SkeletonOf(hd);
## Skeleton of  &lt;trans. semigroup of size 3125 with 4 generators&gt;,
## image sets: 31, equivalence classes: 5, levels: 4
##  </Example> 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction("SkeletonOf");

#############################################################################
##  <#GAPDoc Label="GroupComponents">
##  <ManSection><Heading>The group components</Heading>
##  <Func Name="GroupComponents" Arg="holdecomp, depth"/>
##  <Description>
##  Returns the list of (parallel) group components on the given depth of a holonomy decomposition. 
##  <Example>
##  </Example> 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction("GroupComponentsOnDepth");

#############################################################################
##  <#GAPDoc Label="Coordinates">
##  <ManSection><Heading>Cover Chains and Coordinates</Heading>
##  <Func Name="Coordinates" Arg="holdecomp, coverchain"/>
##  <Func Name="CoverChain" Arg="holdecomp, coordinates"/>
##  <Description>
##  Lift for states are essentially cover (inclusion) chains to a singleton from the full state set, but 
## they have to be encoded with respect to representative elements. These function convert back and forth.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction("Coordinates");
DeclareGlobalFunction("CoverChain");

#############################################################################
##  <#GAPDoc Label="ActionInfoOnLevel">
##  <ManSection><Heading>Information on the action of a component on a level</Heading>
##  <Func Name="ActionInfoOnLevel" Arg="holdecomp, level"/>
##  <Description>
##  This gives textual information on the action of the components on a given level.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction("ActionInfoOnLevel");

## just give the new we want to switch to
DeclareGlobalFunction("ChangeCoveredSet");

DeclareGlobalFunction("DotHolonomy");
DeclareGlobalFunction("SplashHolonomy");
