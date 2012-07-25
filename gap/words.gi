#############################################################################
##
## words.gi           SgpDec package
##
## Copyright (C)
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Algorithms with words (sequences of integers usually coding generators).
##

################################################################################
### ALGORITHM FOR WORDS ########################################################

#general construction from a word coding by applying the generators in order
InstallGlobalFunction(Construct,
function(sequence, generators, start, action)
local product,i;
  product := start;
  for i in [1..Length(sequence)] do
    product := action(product, generators[sequence[i]]);
  od;
  return product;
end);

#the same as Construct, but keeping the intermediate points
InstallGlobalFunction(Trajectory,
function(sequence, generators, start,action)
local trajectory,i;
  trajectory := [start]; #so the images are off by 1
  for i in [1..Length(sequence)] do
    Add(trajectory,action(trajectory[i], generators[sequence[i]]));
  od;
  return trajectory;
end);

InstallGlobalFunction(IsStraightWord,
function(word, gens, start, action)
local i,t,trajectory;
  trajectory := Trajectory(word, gens, start,action);
  #if the first element is also at the end, we remove the last
  if (trajectory[1] = trajectory[Length(trajectory)]) then
    Remove(trajectory);
  fi;
  return IsDuplicateFreeList(trajectory);
end);

#based on the trajectory we cut out loops from the word
StraightenWord := function(word, trajectory)
local reduced, pointer, duplicate, shift;
  shift:=1; #there is an extra element in the trajectory (the starting point)
  #loops are allowed in the definition so we remove that starting of the loop
  if (trajectory[1] = trajectory[Length(trajectory)]) then
    Remove(trajectory,1);
    shift := 0;
  fi;
  #we will cut pieces out of the word thus it has to be mutable
  reduced := ShallowCopy(word);
  pointer := Length(trajectory);
  while pointer > 0 do
    duplicate := Position(trajectory, trajectory[pointer]);
    if duplicate = pointer then
      #no duplication - so just go to the previous element
      pointer := pointer - 1;
    else
      #cutting out the loop
      Perform([duplicate+1..pointer],
              function(i) Unbind(reduced[i-shift]); end);
      pointer := duplicate - 1;
    fi;
  od;
  return Compacted(reduced);
end;
MakeReadOnlyGlobal("StraightenWord");

#this is just a wrapper that calculates the required trajectory
InstallGlobalFunction(Reduce2StraightWord,
function(word, gens, point, action)
  return StraightenWord(word,Trajectory(word,gens,point,action));
end);

#l - length of the word, n - number of generators
InstallGlobalFunction(RandomWord,
function(l,n)
local list;
  list := [1..n];
  return List([1..l], x->Random(list));
end);

################################################################################
# INVERSES included in the words ###############################################

InstallGlobalFunction(AugmentWithInverses,
function(gens)
  return Concatenation(gens, List(gens, x -> Inverse(x)));
end);

InstallGlobalFunction(DecodeAugmentedInverses,
function(w,n)
  return List(w, function(x) if x > n then return -(x-n); else return x;fi;end);
end);

InstallGlobalFunction(ConstructWithInverses,
function(sequence, generators, start, action)
local product,i;
  product := start;
  for i in [1..Length(sequence)] do
    if sequence[i] > 0 then
      product := action(product, generators[sequence[i]]);
    else
      #This works only for invertible generators, so one should be careful!
      #TODO calculating the inverses could be useful
      product := action(product, Inverse(generators[-sequence[i]]));
    fi;
  od;
  return product;
end);

InstallGlobalFunction(TrajectoryWithInverses,
function(sequence, generators, start,action)
local trajectory,i;
  trajectory := [start]; #so the images are off by 1
  for i in [1..Length(sequence)] do
    if sequence[i] > 0 then
      Add(trajectory,action(trajectory[i], generators[sequence[i]]));
    else
      Add(trajectory,action(trajectory[i], Inverse(generators[-sequence[i]])));
    fi;
  od;
  return trajectory;
end);

InstallGlobalFunction(Reduce2StraightWordWithInverses,
function(word, gens, point, action)
    local reduced;
    #we reduce the word symbolically first (cancelling inverses)
    reduced := ReducePermutationWord(word);
    #we create the trajectory by the invertible word and also cancel
    return StraightenWord(ReducePermutationWord(reduced),
                   TrajectoryWithInverses(reduced,gens,point,action));
end);

InstallGlobalFunction(InvertPermutationWord,
function(sequence)
local i,inverted;
  inverted := [];
  for i in Reversed([1..Length(sequence)]) do
    Add(inverted, -sequence[i]);
  od;
  return inverted;
end);

#just the usual cancellation of inverses
InstallGlobalFunction(ReducePermutationWord,
function(sequence)
local i;
  i:=1;
  while i <  Length(sequence) do
    if sequence[i] = (-sequence[i+1]) then
      Remove(sequence,i+1);#these shift the above elements
      Remove(sequence,i);
      if i > 1 then i := i -1; fi; # there can be some further collapsings
    else
      i := i+1;
    fi;
  od;
  return sequence;
end);

#l - length of the word, n - number of generators
InstallGlobalFunction(RandomWordWithInverses,
function(l,n)
local list;
  list := Concatenation([1..n],[1..n]*-1);
  return List([1..l], x->Random(list));
end);

################################################################################
# BACKTRACK BASED ENUMERATION OF STRAIGHT WORDS ################################

# processor can be any function taking two arguments:
# the word and the resulting point, when collecting the word it has to be copied

# for instance for printing all straightwords
InstallGlobalFunction(SWP_Print,
function(word, result)
  Print(result,":", word,"\n");
end);

SWP_Collector :=
function(cargo)
  return function(word,elm)
    Add(cargo,[ShallowCopy(word),elm]);
  end;
end;

# full backtrack on all straightword
InstallGlobalFunction(AllStraightWords,
function(start, gens,action, processor,limit)
local recursion;
  #======================================================
  recursion := function(word, trajectory)
    local t,i,pt, pos;

    processor(word, trajectory[Length(trajectory)]);
    ####################################################
    if (Length(word) < limit) then
      #do the recursion bit - no new list is allocated
      for i in [1..Length(gens)] do
        Add(word,i);
        pt := action(trajectory[Length(trajectory)],gens[i]);
        pos := Position(trajectory, pt);
        if pos = fail then
          #if not contained in trajectory then recurse
          Add(trajectory, pt);
          recursion(word,trajectory);
          Remove(trajectory);
        else
          #we do nothing, except for genuine loops we process
          if pos = 1 then
            processor(word, pt);
          fi;
        fi;
        Remove(word);
      od;
    fi;
  end;
  #======================================================
  # the start of recursion
  recursion([],[start]);
end);

#straightwords from start to finish
InstallGlobalFunction(StraightWords,function(start, finish, gens, action,limit)
local l, collector;
  l := [];
  #---------------------------------------------------
  collector := function(word,result)
    if result = finish then
      Add(l, ShallowCopy(word));
    fi;
  end;
  #---------------------------------------------------

  AllStraightWords(start,gens, action, collector,limit);
  return l;
end);