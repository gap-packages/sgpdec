#############################################################################
##
## cascadedstructure.gd           SgpDec package  
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
## 2008 University of Hertfordshire, Hatfield, UK
##
## Each cascaded product needs a detailed type structure. Here are the decalrations of tools 
## needed for that task.
##

DeclareCategory("IsCascadedStructure", IsDenseList);

DeclareRepresentation( "IsCascadedStructureRep",
                       IsComponentObjectRep,
                       [ "components",                  #the building blocks
                         "name_of_product",             #the name of the whole product structure #TODO!!! maybe replacing by SetName?
                         "state_symbol_functions",      #the symbols for printing the the states
                         "operation_symbol_functions",  #the symbols for printing the the operations
                         "names_of_components",         #the groups are named by StructureDescription, semigroups should have names attached
                         "argument_names",            #the names of the subproduct of the components as domains for the depfunctions

                         "state_sets",         #the original statesets
                         "states",             #states as cascaded states with correct type
                         "maxnum_of_dependency_entries", #the maximum number of elementary dependencies in a cascaded operation


                         "operation_family",          #family for the operations
                         "operation_type",            #type for operations
                         "state_family",              #family for the states
                         "state_type",                #type for states
                         "state_representation",      #representation for states
                         "abstract_state_family",              #family for the states
                         "abstract_state_type",                #type for states
                         "abstract_state_representation"      #representation for states
                         ] );

CascadedStructureType  := NewType(
    NewFamily("CascadedStructureFamily",IsCascadedStructure),
    IsCascadedStructure and IsCascadedStructureRep);


#############################################################################
##
##      <#GAPDoc Label="CascadedStructure">
##      <ManSection><Heading>CascadedStructure</Heading>
##      <Oper Name="CascadedStructure" Arg="components"/>
##      <Oper Name="CascadedStructure" Arg="components, statesymfuncs, opsymfuncs"/>
##      <Description>
##      <C>CascadedStructure</C> builds a cascaded structure from the given list of
##      <C>components</C>. The components are either permutation groups or transformation 
##      semigroups. The cascaded structure itself is just a framework in which 
##  cascaded states and operations can be instantiated, therefore creating a cascaded structure
##  is quick while calculating in it may be very computation intensive.
##      <P/>
##      The symbol functions are lists of functions for each components mapping states and 
##      operations to strings. If they are not specified  the functions return the default string
##      representations of integer numbers.
##      <Example>
##  flipflop := SemigroupByGenerators([
##                  Transformation([1,1]),
##                  Transformation([2,2]),
##                  Transformation([1,2])]);
##  Z3 := CyclicGroup(IsPermGroup,3);
##  Z3FF := CascadedStructure([Z3,flipflop]);
##      </Example> 
##      </Description>
##      </ManSection>
##      <#/GAPDoc>
DeclareOperation("CascadedStructure",[IsList,IsList,IsList]);


#############################################################################
##
##      <#GAPDoc Label="CascadedYEAST">
##      <ManSection><Heading>Moving between the 'Flat' and the Cascaded</Heading>
##      <Oper Name="Build" Arg="cascadedstruct,flatobj"/>
##      <Oper Name="BuildNC" Arg="cascadedstruct,flatobj"/>
##      <Oper Name="Collapse" Arg="cascadedobj"/>
##      <Description>
##      A cascaded structure can be viewed as a flat structure: for a flat state/operation
##      one can build a cascaded one, or one can collapse a hierarchical structure. 
##      The non-check version is faster but should be used only when the flat operation is known to be in the cascaded structure.
##      <P/>
##
##      These operations are defined for both operations and states and can be considered as the
##      low-level version of <C>Raise</C> and <C>Flatten</C> in  <Ref Chap="HierarchicalDecompositions" Style="Text"/>.  
##      </Description>
##      </ManSection>
##      <#/GAPDoc>
DeclareOperation("Collapse",[IsObject]);
DeclareOperation("Build",[IsObject]);
DeclareOperation("BuildNC",[IsObject]);

#############################################################################
##
##      <#GAPDoc Label="MonomialGenerators">
##      <ManSection><Heading>Constructing monomial generators for the wreath product</Heading>
##      <Func Name="MonomialGenerators" Arg="cascadedstruct"/>
##      <Description>
##      The wreath product (the full structure on the given components) can be generated by
##      monomial generators, i.e. cascaded operations containing only one elementary dependence.
##      For cascades of groups it returns a minimal set of monomial generators, but for semigroups it may not.
##      </Description>
##      </ManSection>
##      <#/GAPDoc>
DeclareGlobalFunction("MonomialGenerators");

DeclareGlobalFunction("SizeOfWreathProduct");

#ACCESS FUNCTIONS
DeclareGlobalFunction("States");
DeclareGlobalFunction("StateSets");
DeclareGlobalFunction("MaximumNumberOfElementaryDependencies");
DeclareGlobalFunction("NameOf"); #TODO! this may be just standard Name?!?
