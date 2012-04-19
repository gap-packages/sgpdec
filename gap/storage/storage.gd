#############################################################################
##
## storage.gd           SgpDec package  
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
## 2010 University of Hertfordshire, Hatfield, UK
##
## Abstract type for different kind of storage data structures (stack, queue).
##

#a storage is a collection but gives some policy on retrieving the elements
DeclareCategory("IsStorage", IsCollection);

#############################################################################
## <#GAPDoc Label="Store">
##  <ManSection><Heading>Storing elements</Heading>
##   <Func Name="Store" Arg="storage,element"/>
##    <Description>
##    Stores one element (any type) in a given storage.
##   </Description>
##  </ManSection>
## <#/GAPDoc>
DeclareOperation("Store",[IsStorage,IsObject]);

#############################################################################
## <#GAPDoc Label="Retrieve">
##  <ManSection><Heading>Retrieving elements</Heading>
##   <Func Name="Retrieve" Arg="storage"/>
##    <Description>
##    Retrieves the  next element according to some rules (LIFO for queus, FIFO for stacks).    
##   </Description>
##  </ManSection>
## <#/GAPDoc>
DeclareOperation("Retrieve",[IsStorage]);

#############################################################################
## <#GAPDoc Label="Peek">
##  <ManSection><Heading>Peeking into a storage.</Heading>
##   <Func Name="Peek" Arg="storage"/>
##    <Description>
##    Returns the next element but it is not removed from the storage, i.e. a dry-run of Retrieve.
##   </Description>
##  </ManSection>
## <#/GAPDoc>
DeclareOperation("Peek",[IsStorage]);
