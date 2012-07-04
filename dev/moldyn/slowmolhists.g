#Systematically checking all words with a given length l, whether they 
#permute a subset. It is also checked whether it is a nontrivial permutation or not.
howmany_permutations := function(transfs, finset,l) 
local words,numofperms,numofids,t,w;
  
  numofperms := 0;
  numofids := 0;
  #the cartesian product of l copies of the generator set 
  words := VL_Cartesian(List([1..l], x->[1..Length(transfs)]));

  for w in words do
    t := IntegerSequence2Transformation(w,transfs);
    if finset = finset * t then
      numofperms := numofperms + 1;
      Print(w," "); Display(LinearNotation(t));
      #if IsIdentityOnSet(t,finset) then
      #  numofids := numofids + 1;
      #fi;
    fi;
  od;

  Print("L ", l , " : " ,  numofperms ,"\n");
end;;

##
howmany_nonfallers := function(transfs, finset,l) 
local words,numofnonfallers,t,w, size;

  size := Size(finset);
  #the cartesian product of l copies of the generator set 
  words := VL_Cartesian(List([1..l], x->transfs));
  numofnonfallers := 0;

  for w in words do
    t := Product(w);
    if not (Size(ImageSetOfTransformation(t)) < size) then
      numofnonfallers := numofnonfallers + 1;
    fi;
  od;

  Print(l , " " ,  FLOAT_INT(numofnonfallers)/FLOAT_INT(Length(words)), "\n");
end;;

