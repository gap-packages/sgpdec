##########################################################################
##
## linearnotation.gd           SgpDec package  
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
## 2009 University of Hertfordshire, Hatfield, UK
##
## One line notation for transformations.

##  <#GAPDoc Label="LinearNotation">
##  <ManSection >
##  <Func Arg="transformation" Name="LinearNotation" />
##  <Func Arg="transformation" Name="SimplerLinearNotation" />
##  <Description>
##  Returns the linear (one-line) notation of the given finite transformation as a string. 
##  <Example>
##gap> LinearNotation(Transformation([1,1,1,1])); #constant map           
##"[2,3,4;1]"
##gap> LinearNotation(Transformation([2,3,4,1])); #cyclic permutation
##"(1,2,3,4)"
##gap> LinearNotation(Transformation([1,1,2,2,4]));
##"[[3,[5;4];2];1]"  # 1 forms a trivial cycle, 2,3,4 go to 1, 5 goes to 4
##gap> LinearNotation(Transformation([2,1,2,2,4]));
##"(1,[3,[5;4];2])"  # swapping 1 and 2 and the other points go to 2          
##</Example>
##However, for constant map we can apply another simplification: 
##<Example>
##gap> SimplerLinearNotation(Transformation([5,5,5,5,5]));
##"[->5]"  # short notation for constants
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction("LinearNotation");
DeclareGlobalFunction("SimplerLinearNotation");
