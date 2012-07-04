BruteForceTSEnum := function(n)
  local trans, ssgs, bitlist, bl, gens, nn,i, nonsgs, duplicates;
  nn := n^n;
  nonsgs := 0;
  duplicates := 0;
  ssgs := [];
  trans := AsSortedList(FullTransformationSemigroup(n));
  bitlist := LazyCartesian( List ([1..nn], x-> [false,true]) );
  for i in [2..2^nn] do
    gens := [];
    bl := bitlist[i];
    Perform([1..nn], function(x) if bl[x] then Add(gens, trans[x]);fi;end);
    #Display(i);
    if Size(gens) = Size(Semigroup(gens)) then
      if gens in ssgs then
        duplicates := duplicates + 1;
      else
        AddSet(ssgs,gens);
      fi;
    else
      nonsgs := nonsgs + 1;
    fi;
    if (i mod 1000000) = 0 then
      Print("#", Size(sgs), "\c");
    fi;
  od;
  Print("#I Subsemis:", Size(ssgs),
        " Duplicates:", duplicates,
        " Nonsgs:", nonsgs,"\n");
  return ssgs;
end;
