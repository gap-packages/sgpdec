# backtrack enumeration of subsemigroups of a full transformation semigroup

#just plain lists, this way it is easy to associate an ordinal number, we will convert to Transformation
trans := []; #initialized by longholsearch - quickfix
counter := 0;
sgs := [];

backtrack := function(gens) 
    local ts,j;
    counter := counter +1;
    if (counter mod 10000)  = 0 then 
        GASMAN("collect");# we need explicit call otherwise it breaks down - maybe this is the right place to call (not too often)
        counter := 0;
    fi;
    ts := Semigroup(trans{gens});
    if IsFullTransformationSemigroup(ts) then return;fi;
    AddSet(sgs,AsSortedList(ts));
    for j in [LastElementOfList(gens)+1..Size(trans)] do
        if not (trans[j] in ts) then 
            Add(gens,j);
            backtrack(gens);
            Remove(gens);
        fi;
    od;

end;

# we are looking for the longest holonomy decomposition
longholsearch := function(n)    
local i;
    trans := AsSortedList(FullTransformationSemigroup(n));

    for i in [1..Size(trans)] do 
      Print("#");Display(i);
      backtrack([i]);
    od;
end;

longholsearch(2);

Perform(sgs, Display);
