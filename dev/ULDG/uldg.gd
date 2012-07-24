##########################################################################
##
## uldg.gd           SgpDec package  
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
## 2009 University of Hertfordshire, Hatfield, UK
##
## Functions for giving generators for special uniquely labelled 
## state transition graphs. 

## 1. PART 
##Functions for making transformation(s) from elementary collapsing(s).

##  <#GAPDoc Label="TransformationFromElementaryCollapsing">
##  <ManSection><Heading>TransformationFromElementaryCollapsing</Heading>
##  <Func Name="TransformationFromElementaryCollapsing" Arg="collapsing,n"/>
##  <Func Name="TransformationsFromElementaryCollapsings" Arg="collapsings,n"/>
##  <Description>
##  <Example>
##   gap> TransformationFromElementaryCollapsing([3,2],6);
## Transformation( [ 1, 2, 2, 4, 5, 6 ] )
## gap> TransformationsFromElementaryCollapsings([[3,2],[1,2],[6,2]],6);
##[ Transformation( [ 1, 2, 2, 4, 5, 6 ] ),
##  Transformation( [ 2, 2, 3, 4, 5, 6 ] ),
##  Transformation( [ 1, 2, 3, 4, 5, 2 ] ) ]
## </Example>
##  </Description>
##  </ManSection>
##   <#/GAPDoc>
DeclareGlobalFunction("TransformationFromElementaryCollapsing");
DeclareGlobalFunction("TransformationsFromElementaryCollapsings");


## 2. PART 
## The graphs

##  <#GAPDoc Label="GammaGraph">
##  <ManSection><Heading>GammaGraph</Heading>
##  <Func Name="GammaGraph" Arg="l,k"/>
##  <Description>
##  Creates a uniquely labelled graph of a cylce with length l and cutting through from point 1 to point k. A uniquely labelled graph can be considered as a set of elementary collapsings.
##  <Example>
##gap> GammaGraph(5,4);
##[ [ 1, 2 ], [ 2, 3 ], [ 3, 4 ], [ 4, 5 ], [ 5, 1 ], [ 1, 4 ] ]
## </Example>
##  </Description>
##  </ManSection>
##   <#/GAPDoc>
DeclareGlobalFunction("GammaGraph");

##  <#GAPDoc Label="DeltaGraph">
##  <ManSection><Heading>DeltaGraph</Heading>
##  <Func Name="DeltaGraph" Arg="m,n"/>
##  <Description>
##  Creates a uniquely labelled graph of two cycles of length m and n sharing exactly one node. A uniquely labelled graph can be considered as a set of elementary collapsings.
##  <Example>
##  gap> DeltaGraph(2,3);
##  [ [ 1, 2 ], [ 2, 1 ], [ 1, 3 ], [ 3, 4 ], [ 4, 1 ] ]
## </Example>
##  </Description>
##  </ManSection>
##   <#/GAPDoc>
DeclareGlobalFunction("DeltaGraph");
DeclareGlobalFunction("OldBetaGraph");
DeclareGlobalFunction("BetaGraph");
DeclareGlobalFunction("ThetaGraph");
## Two overlapping cycles sharing a directed path of edges

