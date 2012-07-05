#############################################################################
##
## decomposition.gi           SgpDec package  
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
## 2008 University of Hertfordshire, Hatfield, UK
##
## The abstract datatype for hierarchical decompositions.
##


#returning original structure
InstallGlobalFunction(OriginalStructureOf,
function(decomp)
  return decomp!.original;
end
);


# returning underlying cascaded structure
InstallMethod(CascadedStructureOf," hierarchical decompositions",true,[IsHierarchicalDecomposition], 
function(decomp)
  return decomp!.cascadedstruct;
end
);

#clusters the elements of a permutation group according to their dependency graphstructure
InstallGlobalFunction(DependencyClassesOfDecomposition,
function(decomp)
local origstruct,cpi,element,i,cascop,dg,depgraphs,freqs,pos,cstr,dep,deps;
  origstruct := OriginalStructureOf(decomp);
  cstr := CascadedStructureOf(decomp);
  #first getting the types of depgraphs
  depgraphs := [];
  for element in origstruct do
    cascop := Raise(decomp,element);
    dg := DependencyGraph(cascop);
    if not (dg in depgraphs) then Add(depgraphs,dg); fi;
  od;
  Sort(depgraphs);
  #then counting the frequencies and storing the permutations with that dependency graphs
  #starting with zeros and the empty list
  freqs := List([1..Size(depgraphs)],x->[0,[]]);
  for element in origstruct do
    cascop := Raise(decomp,element);
    dg := DependencyGraph(cascop);
    pos := Position(depgraphs,dg);
    freqs[pos][1] := freqs[pos][1]+1;
    Add(freqs[pos][2],element);
  od;
  
  for i in [1..Size(depgraphs)] do Print(freqs[i][1],": ",depgraphs[i],"\n",freqs[i][2],"\n") ;od;
  #putting together all the individual dependencies 
  deps := [];
  for dg in depgraphs do
    for dep in dg do
      if not (dep in deps) then
        Add(deps,dep);
      fi;
    od;
  od;
  Print("All individual dependencies:\n");
  Display(deps);
end);



#######################OLD METHODS################################################

# The size of the decomposition, i.e. the number of components.
InstallOtherMethod(Length,"for hierarchical decompositions", true, [IsHierarchicalDecomposition], # simple InstallMethod did not work
function(decomp)
  return Length(decomp!.cascadedstruct);
end
);
