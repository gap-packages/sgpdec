##########################################################################
##
## permutator.gi           SgpDec package  
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
## 2009 University of Hertfordshire, Hatfield, UK
##
## Functions for finding elements of a transformation semigroups
## that permute a subset of the state set.
## 
## Depends on straight words.

#finding permutator elements by full enumeration of the elements of the transformation semigroup
#useful for testing the more efficient algorithms
InstallGlobalFunction(AllPermutatorsByFullEnumeration,
function(finiteset, ts)
local permutators, transformation, semigroup;
  #2nd parameter is either a set of generators or a transformation semigroup, we need the semigroup
  if IsList(ts) then 
    semigroup := SemigroupByGenerators(ts);
  else
    semigroup := ts;
  fi;  
 
  permutators := [];
  #full enumeration
  for transformation in semigroup do
    if OnFiniteSets(finiteset,transformation) = finiteset then
      Add(permutators, transformation);
    fi;  
  od;
  return permutators;
end
);


InstallGlobalFunction(PermutatorSplitter,
function(word, finset, transfs)
local chunks,i,t,lastsplit;
  chunks := [];
  i := 1;
  lastsplit := 0;
  while i <= Length(word) do 
    t := Construct(word{[1..i]},transfs,One(transfs[1]),\*); 
    if finset * t = finset then
      Add(chunks, word{[lastsplit+1..i]});
      lastsplit := i;
    fi;
    i := i+1;
  od;
  return chunks;
end
);

InstallGlobalFunction(IsMinimalPermutator,
function(word,  finset, transfs)
local chunks;
  chunks := PermutatorSplitter(word,finset,transfs);
  return (Length(chunks) = 1) and (Length(word) = Length(chunks[1])); 
  #if the word is not a permutator, the chunk may be shortened
end
);
