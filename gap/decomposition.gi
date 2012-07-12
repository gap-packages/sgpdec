#############################################################################
##
## decomposition.gi           SgpDec package
##
## (C) Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## 2008-2012
##
## The abstract datatype for hierarchical decompositions.
##

#returning original structure
InstallGlobalFunction(OriginalStructureOf,
function(decomp)
  return decomp!.original;
end);

# returning underlying cascaded structure
InstallMethod(CascadedStructureOf,
        "for hierarchical decompositions",true,[IsHierarchicalDecomposition],
function(decomp)
  return decomp!.cascadedstruct;
end);

#######################OLD METHODS##############################################

# The size of the decomposition, i.e. the number of components.
InstallOtherMethod(Length,"for hierarchical decompositions",
        true, [IsHierarchicalDecomposition],
function(decomp)
  return Length(decomp!.cascadedstruct);
end);
