##########################################################################
##
## permutator.gd           SgpDec package  
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
## 2009 University of Hertfordshire, Hatfield, UK
##
## Functions for finding elements of a transformation semigroups
## that permute a subset of the state set.
##
## Depends on straight words.

##  <#GAPDoc Label="PermutatorSplitter">
##  <ManSection><Heading>PermutatorSplitter</Heading>
##  <Func Name="PermutatorSplitter" Arg="word, finset, transfs"/>
##  <Description>
##  Returns a list of the straight word factorization of the permutator word.
##  <Example>
##  </Example>
##  </Description>
##  </ManSection>
##   <#/GAPDoc>
DeclareGlobalFunction("PermutatorSplitter");

##  <#GAPDoc Label="IsMinimalPermutator">
##  <ManSection><Heading>IsMinimalPermutator</Heading>
##  <Func Name="IsMinimalPermutator" Arg="word, finset, transfs"/>
##  <Description>
##  Returns true if the word represents a minimal (straight) permutator
##  using the set of transformations as generators and on the given finiteset.
##  <Example>
##  </Example>
##  </Description>
##  </ManSection>
##   <#/GAPDoc>
DeclareGlobalFunction("IsMinimalPermutator");