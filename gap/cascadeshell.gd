#############################################################################
##
## cascadeshell.gd           SgpDec package
##
## Copyright (C) 2008-2012
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## An empty shell defined by an ordered list of components.
## Used for defining cascaded structures.
##

DeclareOperation("CascadeShell",[IsList,IsList,IsList]);
DeclareGlobalFunction("SizeOfWreathProduct");
DeclareGlobalFunction("MaximumNumberOfElementaryDependencies");

#ACCESS FUNCTIONS
DeclareGlobalFunction("States");
DeclareGlobalFunction("StateSets");

DeclareCategory("IsCascadeShell", IsDenseList);
DeclareProperty("IsCascadedGroupShell", IsCascadeShell);

DeclareRepresentation(
        "IsCascadeShellRep",
        IsComponentObjectRep,
        [ "components", #the building blocks
          "name_of_shell",
          "state_symbol_functions", #the symbols for printing the the states
          "operation_symbol_functions", #the symbols for printing the operations
          "argument_names", #the names argument domains
          "state_sets", #the original statesets
          "states", #states as cascaded states with correct type
          "maxnum_of_dependency_entries" #the maximum number of elementary deps
          ]);

CascadeShellType :=
  NewType(NewFamily("CascadeShellFamily",IsCascadeShell),
          IsCascadeShell and IsCascadeShellRep);