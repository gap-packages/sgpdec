#############################################################################
##
## cascadedstructure.gd           SgpDec package
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## 2008-2012
##
## Putting algebraic structures into hierarchical structures.
##

DeclareOperation("CascadedStructure",[IsList,IsList,IsList]);
DeclareOperation("Collapse",[IsObject]);
DeclareOperation("Build",[IsObject]);
DeclareOperation("BuildNC",[IsObject]);
DeclareGlobalFunction("MonomialGenerators");
DeclareGlobalFunction("SizeOfWreathProduct");

#ACCESS FUNCTIONS
DeclareGlobalFunction("States");
DeclareGlobalFunction("StateSets");
DeclareGlobalFunction("MaximumNumberOfElementaryDependencies");
DeclareGlobalFunction("NameOf"); #TODO! this may be just standard Name?!?


DeclareCategory("IsCascadedStructure", IsDenseList);
DeclareRepresentation(
        "IsCascadedStructureRep",
        IsComponentObjectRep,
        [ "components",         #the building blocks
          "name_of_product",    #the name of the whole product structure
          #TODO!!! maybe replacing by SetName?
          "state_symbol_functions",  #the symbols for printing the the states
          "operation_symbol_functions", #the symbols for printing the operations
          "names_of_components",        #the groups are named by StructureDescription, semigroups should have names attached
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
          ]);

CascadedStructureType  := NewType(
                            NewFamily("CascadedStructureFamily",
                                       IsCascadedStructure),
                            IsCascadedStructure and IsCascadedStructureRep);