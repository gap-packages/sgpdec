#investigating the top level component
T3 := FullTransformationSemigroup(3);
sk := Skeleton(T3);

Classify := function(elts, f)
 local e, #an elemenet from elts
       d, #data constructed from e, f(e)
       m; #hashmap for the final result
  m := HashMap();
  for e in elts do
    d := f(e);
    if d in m then
      Add(m[d], e);
    else
      m[d] := [e];
    fi;
  od;
  return m;
end;

#returns a hashmap mapping a top level action the original transformation
TopLevelActionPreImages := function(S)
local f,sk;
sk := Skeleton(S);
f := x -> OnDepArg([],DependencyFunctionsOf(AsHolonomyCascade(x,sk))[1]);
 return Classify(S, f);
end;

#based on the previous hashmap, we map top level actions to set of image set of the preimage transformations 
TopLevelPreImageImageSets := function(m)
local nm;
nm := HashMap();
Perform(Keys(m),
        function(k)
          nm[k] := AsSet(List(m[k], ImageSetOfTransformation));
        end);
return nm;      
end;

PrintHashMap := function(m)
local k;
for k in Keys(m) do
  Print(k);
  Print("->");
  Print(m[k]);
  Print("\n");
od;
end;