TestStraightWords := function(gens,length)
local t,w,rw,i;
  t := Runtime();
  Print("Reducing random words of length ", length ," for straightness...\n");
  for i in [1..10] do
    if IsPerm(gens[1]) then
      w := RandomWordWithInverses(length,Size(gens));
    else
      w := RandomWord(length,Size(gens));
    fi;
    rw := Reduce2StraightWord(w,gens,One(gens[1]));
    Print(" ",Length(w),"->", Length(rw), " ");
    if Size(w) <> 0 then
      Print(" reduced to ",
            FormattedPercentageString(Size(Compacted(rw)),Size(w)),"\n\c");
    fi;
    if (not IsStraightWord(w,gens,One(gens[1]),\*))
       and (Length(rw) >= Length(w)) then
      Print("FAIL\n");
      Error("Straight word reduction does not produce shorter word!\n");
    fi;
    if (not IsStraightWord(rw,gens,One(gens[1]),\*)) then
      Print("FAIL\n");
      Error("Straight word reduction does not produce straight word!\n");
    fi;
    if Construct(w,gens,One(gens[1]),\*)
       <> Construct(rw,gens,One(gens[1]),\*) then
      Print("FAIL\n");Error("Reduction does not give identical operation!\n");
    fi;
  od;
  Print("Done  in",Runtime() - t,"ms.\n");
  #TODO!! do transformation checks as well
  Print("PASSED\n");
end;