#############################################################################
##
## cascadedoperation.gd           SgpDec package  
##
## (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Cascaded permutations and transformations.
##

#############################################################################
##
##      <#GAPDoc Label="IsCascadedOperation">
##      <ManSection><Heading>Types of Cascaded Operations</Heading>
##      <Filt Name="IsCascadedOperation" Arg="obj" Type="Category"/>
##      <Filt Name="IsCascadedTransformation" Arg="obj" Type="Category"/>
##      <Filt Name="IsCascadedPermutation" Arg="obj" Type="Category"/>
##      <Description>
##      Cascaded operations are multiplicative elements thus the <C>*</C> and the exponent can be used.
##      If the components are only groups then we have cascaded permutations,
##      otherwise we have cascaded permutations.   
##      </Description>
##      </ManSection>
##      <#/GAPDoc>
DeclareCategory("IsCascadedOperation", IsMultiplicativeElement);
# somewhat unmathematical but we need to handle transformations and permutations differently
DeclareCategory("IsCascadedPermutation", IsCascadedOperation and IsMultiplicativeElementWithInverse);
DeclareCategory("IsCascadedTransformation", IsCascadedOperation);


#######FOR CREATING ELEMENTS OF CASCADE PRODUCT###########################
#############################################################################
##
##      <#GAPDoc Label="IdentityCascadedOperation">
##      <ManSection><Heading>Creating the Identity Operation</Heading>
##      <Func Name="IdentityCascadedOperation" Arg="cascadedstruct"/>
##      <Description>
##      Creates the identity cascaded operation for a given cascaded structure.
##      </Description>
##      </ManSection>
##      <#/GAPDoc>
DeclareGlobalFunction("IdentityCascadedOperation");
#the constructor from a dependency function table
DeclareGlobalFunction("CascadedOperation");

#############################################################################
## <#GAPDoc Label="RandomCascadedOperation">
## <ManSection><Heading>Creating a Random Operation</Heading>
## <Func Name="RandomCascadedOperation" Arg="cascadedstruct,numofdeps"/>
## <Description>
##   Creates a random cascaded operation for a given cascaded structure.
##   The number of elementary dependecies should also be given. This is a maximum number,
##   and it is not guaranteed to have that many.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction("RandomCascadedOperation");

#############################################################################
##
##      <#GAPDoc Label="DefineCascadedOperation">
##      <ManSection><Heading>Creating a Cascaded Operation from Dependencies</Heading>
##      <Func Name="DefineCascadedOperation" Arg="cascadedstruct, dependencies"/>
##      <Description>
##      Creates a  cascaded operation from a set of dependencies.
##      The argument <C>dependencies</C> contains a list of pairs, where one abstract state 
##      (as a plain list)  -  component action pair is an elementary dependence. 
##      </Description>
##      </ManSection>
##      <#/GAPDoc>
DeclareOperation("DefineCascadedOperation",[IsObject,IsListOrCollection]); #first argument cannot be more specific as it would be an early reference

#############################################################################
## <#GAPDoc Label="DependencyMapsFromCascadedOperation">
## <ManSection><Heading>Extracting Dependencies</Heading>
## <Func Name="DependencyMapsFromCascadedOperation" Arg="cascadedop"/>
## <Description>
##   Extracts dependencies from a cascaded operation. The dependencies then can be
##   modified and fed back into <C>DefineCascadedOperation</C>.
##   Note that the cascaded structure need not be given as the operation already 
##   knows about it.
## </Description>
## </ManSection>
## <#/GAPDoc>
DeclareGlobalFunction("DependencyMapsFromCascadedOperation");

#############################################################################
##
##  <#GAPDoc Label="DependsOn">
##  <ManSection><Heading>Dependence</Heading>
##  <Func Name="DependsOn" Arg="cascadedop, targetlevel, onlevel"/>
##  <Description>
##  Checks whether the targetlevel depends on onlevel in cascop.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction("DependsOn");

#############################################################################
##
##  <#GAPDoc Label="DependencyGraph">
##  <ManSection><Heading>The dependency graph</Heading>
##  <Func Name="DependencyGraph" Arg="cascadedop"/>
##  <Description>
##  Returns the dependency graph of a cascaded operation. The graph is represented
##  as a list of ordered pairs [i,j] meaning that level i depends on level j, i.e.
##  by varying the coordinate on level j yields different dependency values.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction("DependencyGraph");


#############################################################################
##
##      <#GAPDoc Label="ProjectedScope">
##      <ManSection><Heading>The projected scope</Heading>
##      <Func Name="ProjectedScope" Arg="cascadedop"/>
##      <Description>
##      Returns the set of levels (the indices) on which the cascaded operation acts nontrivially.
##      </Description>
##      </ManSection>
##      <#/GAPDoc>
DeclareGlobalFunction("ProjectedScope");

#############################################################################
##
##      <#GAPDoc Label="DependencyCompatible">
##      <ManSection><Heading>Dependency Compatibility</Heading>
##      <Func Name="IsDependencyCompatible" Arg="cascadedstructure, flatop"/>
##      <Func Name="IsDependencyCompatible" Arg="cascadedstructure, flatoplist, prefix"/>
##      <Description>
##      Returns true if the flat operation (transformation or permutation) is in the wreath product spanned by
##      the components of the cascaded structure. This means that the dependency functions are well-defined.
##      The second function examines the uniqueness of the dependency value only on a state prefix.
##      </Description>
##      </ManSection>
##      <#/GAPDoc>
DeclareGlobalFunction("IsDependencyCompatible");
DeclareGlobalFunction("IsDependencyCompatibleOnPrefix");

DeclareGlobalFunction("DotCascadedOperation");


