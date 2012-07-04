Read("cascperm.g");

ConstantFunction := function(source,range,value)
   local c,i,sorted_source;
    c := [];
   sorted_source := AsSortedList(source);


  for i in [1..Length(sorted_source)] do
      c[i] := value;
    od;

    #just a lookup function
    return (function(element) # Print("trying to find ",element, " in " ,sorted_s ource,"\n");
return c[Position(sorted_source,element)];end) ;
#  fi;
end;

#identity cascaded permutation 
CPidentity := function(components)
  local levels,cascperm,i,tmp;

  #number of levels
  levels := Size(components);
  #creating new list for the cascaded permutation
  cascperm := [];


  #proceeding by levels
    for i in [1..levels] do
      #choosing the arguments for the dependency function
      tmp := components{[1..(i-1)]};
      #groups to sorted lists
      Apply(tmp,AsSortedList);
      Add(cascperm, ConstantFunction(Cartesian(tmp),components[i],()));
    od;

  return cascperm;
end;

CPpseudoinvert := function(p,comps);
 local pi,levels,tmp; 

  #number of levels
  levels := Size(components);
  #creating new list for the cascaded permutation
  pi := [];

  #proceeding by levels
    for i in [1..levels] do
      #choosing the arguments for the dependency function
      tmp := components{[1..(i-1)]};
      #groups to sorted lists
      Apply(tmp,AsSortedList);
      for j in tmp do
        Add(pi, [j, inverse(p[j])]);
    od;
   od;

return(pi);
end;

i := CPidentity(comps);
CPdraw(i,comps,symbols,"i");


#invert blindly:
CPinv := function(f,components)
local fn,next,i,flati;
i := CPidentity(components); 
flati := CPflat(i,components);
fn := f; next := f;
while not(CPflat(next,components) = flati) 
  do fn := next;
     next := CPmul(fn,f);
     #CPdisp(next,comps);
  od;
return fn; 
end;

CPcommutator := function(p,q,components) 
 return(CPmul(CPmul(CPinv(p,components),CPinv(q,components)),CPmul(p,q)));
end;


comps := [Z5,Z5];
symbols := [Z5symbols,Z5symbols];
p := CPrand(comps);
q := CPrand(comps);

defa := CPdef(comps, [[[ ], (1,2,3,4,5)]]); 

defb := CPdef(comps, [[[()], (1,2,3,4,5)],[[(1,2,3,4,5)],(1,5,4,3,2)]]);

CPdraw(defa,comps,symbols,"a");
CPdraw(defb,comps,symbols,"b");



