#collects recursively all subgroup chains in chains (must be an empty list) starting from the last element of 
AllChains := function(chainfragment, chains)
local i,subgrps, newchainfragment, G, R;
  G := LastElementOfList(chainfragment);
  subgrps := ConjugacyClassesSubgroups(G);
  for i in [1..Length(subgrps)] do
    R := Representative(subgrps[i]);
    if Order(G) <> Order(R) then
      newchainfragment := ShallowCopy(chainfragment);
      Add(newchainfragment, R);
      AllChains(newchainfragment,chains);
      if Order(LastElementOfList(newchainfragment)) <> 1 then Add(newchainfragment, Group(()));fi;
      Add(chains, newchainfragment);
    fi;
  od;
end;
