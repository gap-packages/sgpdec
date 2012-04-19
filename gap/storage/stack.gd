#############################################################################
##
## stack.gd           SgpDec package  
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
## 2010 University of Hertfordshire, Hatfield, UK
##
## Simple stack implementation.
##

DeclareCategory("IsStack", IsStorage);
DeclareRepresentation( "IsStackRep",
                       IsComponentObjectRep,
                       [ "l",      #list containing the elements
                         "pointer" #pointing to the top of the stack
                         ] );

StackType  := NewType(
    NewFamily("StackFamily",IsStack),
    IsStack and IsStackRep and IsMutable);

#############################################################################
## <#GAPDoc Label="Stack">
##  <ManSection><Heading>Creating an empty stack</Heading>
##   <Func Name="Stack" Arg=""/>
##    <Description>
##    Creates an empty stack.    
##    <Example>
##     gap&gt; stack := Stack()
##     Stack: [  ]&lt;-
##    </Example> 
##   </Description>
##  </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction("Stack");


