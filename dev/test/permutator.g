TestPermutator := function(finset, transformations)
local enum_permutators, bf_permutators, t,tp;

  t := Runtime();
  enum_permutators := AllPermutatorsByFullEnumeration(finset, transformations);
  Print("Enumeration in",Runtime() - t,"ms. ", Size(enum_permutators), " permutators found.\n");

  t := Runtime();
  tp := Skeleton(Semigroup(transformations));
  bf_permutators := AllPermutators(tp,finset);
  Print("Constructing permutator words in",Runtime() - t,"ms. ", Size(bf_permutators), " permutators found.\n");

  Print("Sorting and comparing...");
  bf_permutators := ShallowCopy(bf_permutators);
  Sort(bf_permutators);
  Sort(enum_permutators);
  if bf_permutators <> enum_permutators then 
      Print("FAIL\n");Error("Straight words based search gives different results!\n"); 
  fi;


  Print("PASSED\n");

end;  
