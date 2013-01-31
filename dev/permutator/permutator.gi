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

InstallGlobalFunction(PermutatorSplitter,
function(word, finset, transfs)
local chunks,i,t,lastsplit;
  chunks := [];
  i := 1;
  lastsplit := 0;
  while i <= Length(word) do 
    t := BuildByWord(word{[1..i]},transfs,One(transfs[1]),\*); 
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
