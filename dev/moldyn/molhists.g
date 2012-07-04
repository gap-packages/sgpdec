# gives back the product of transformations, or the prefix 
# where the prefix product already collapses too many points
calc_product := function(word, size)
local i,prod;

  prod := word[1];
  i := 2;
  while (Length(ImageSetOfTransformation(prod))>=size) and (i <= Length(word) ) do
    prod :=  prod * word[i];
    i := i + 1;
  od;
  if (i <> Length(word)+1) then 
    return word{[1..i]};
  else
    return prod;
  fi;
end;;


#Systematically checking all words with a given length l, whether they 
#permute a subset. It is also checked whether it is a nontrivial permutation or not.
howmany_permutations := function(transfs, finset,l) 
local words,numofperms,numofids,t,i,N, setsize;

  numofperms := 0;
  numofids := 0;
  #the cartesian product of l copies of the generator set 
  words := VL_Cartesian(List([1..l], x->transfs));
  N := Length(words); 
  setsize := Size(finset);

  i := 1;
  while i <= N  do
#Print(i," ");
    #checking the prefixes
    t := calc_product(words[i],setsize);
    if IsTransformation(t) then
      if finset = finset * t then
        numofperms := numofperms + 1;
        if IsIdentityOnSet(t,finset) then
          numofids := numofids + 1;
        fi;
      fi;
      i := i +1;
    else 
      #skip the ones with the prefix that collapses too many 
     #Print(i," "," ",PositionCanonical(words,VL_CartesianLastWithPrefix(words,t)),"\n"); 
     i := PositionCanonical(words,VL_CartesianLastWithPrefix(words,t)) + 1; 
    fi; 
  od;

  Print(l , " " , numofperms - numofids, "   ", numofperms ," ",numofids,"\n");
end;;

