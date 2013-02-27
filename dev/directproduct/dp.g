DirectProductCascade := function(comps)
  local doms, prefixes, i, gens, cascgens,vals, n, g;
  n := Size(comps);
  doms := ComponentDomains(comps);
  prefixes := CreatePrefixDomains(doms);
  cascgens := [];
  for i in [1..n] do
    gens := GeneratorsOfSemigroup(comps[i]);
    for g in gens do
      vals := List([1..n], x-> []);
      vals[i] := ListWithIdenticalEntries(Size(prefixes[i]),g);
      Add(cascgens,
          CreateCascade(EnumeratorOfCartesianProduct(doms),doms,prefixes,vals));
    od;
  od;
  return Semigroup(cascgens);
end;

IsomorphicPG := function(ts)
  return Group(List(GeneratorsOfSemigroup(ts), AsPermutation));
end;
