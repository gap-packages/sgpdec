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
DeclareGlobalFunction("MonomialGenerators");
DeclareGlobalFunction("SizeOfWreathProduct");

#ACCESS FUNCTIONS
DeclareGlobalFunction("States");
DeclareGlobalFunction("StateSets");
DeclareGlobalFunction("MaximumNumberOfElementaryDependencies");
DeclareGlobalFunction("NameOf"); #TODO! this may be just standard Name?!?

DeclareCategory("IsCascadedStructure", IsDenseList);
DeclareGlobalFunction("IsCascadedGroup");#TODO this must be a filter

DeclareRepresentation(
        "IsCascadedStructureRep",
        IsComponentObjectRep,
        [ "components", #the building blocks
          "name_of_product", #the name of the whole product structure
          "state_symbol_functions", #the symbols for printing the the states
          "operation_symbol_functions", #the symbols for printing the operations
          "names_of_components", #names of the components
          "argument_names", #the names argument domains
          "state_sets", #the original statesets
          "states", #states as cascaded states with correct type
          "maxnum_of_dependency_entries" #the maximum number of elementary deps
          ]);

CascadedStructureType :=
  NewType(NewFamily("CascadedStructureFamily",IsCascadedStructure),
          IsCascadedStructure and IsCascadedStructureRep);
#CascadedGroupType := NewType(NewFamily("CascadedGroupFamily",IsCascadedGroup),
#                             IsCascadedGroup and IsCascadedStructureRep);