#general functions for checking morphisms in different ways

#checking f:S->T homomorphism; Sop, Top are binary operations
#T is not needed as elements in T will be determined by f
CheckHomomorphism := function(S, Sop, Top, f)
  return ForAll(Cartesian(S,S),
                s -> f(Sop(s[1], s[2])) #mult in S, go to T by f
                     =
                     Top(f(s[1]),f(s[2]))); #take elements to T, mult there
end;